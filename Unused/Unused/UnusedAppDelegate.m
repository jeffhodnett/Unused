//
//  UnusedAppDelegate.m
//  Unused
//
//  Created by Jeff Hodnett on 19/11/2011.
//  Copyright 2011 Seamonster Ltd. All rights reserved.
//

#import "UnusedAppDelegate.h"

@implementation UnusedAppDelegate

@synthesize resultsTableView = _resultsTableView;
@synthesize processIndicator = _processIndicator;
@synthesize statusLabel = _statusLabel;
@synthesize window = _window;
@synthesize mCheckbox = _mCheckbox;
@synthesize xibCheckbox = _xibCheckbox;
@synthesize sbCheckbox = _sbCheckbox;
@synthesize cppCheckbox = _cppCheckbox;
@synthesize headerCheckbox = _headerCheckbox;
@synthesize mmCheckbox = _mmCheckbox;
@synthesize htmlCheckbox = _htmlCheckbox;
@synthesize plistCheckbox = _plistCheckbox;
@synthesize cssCheckbox = _cssCheckbox;
@synthesize enumCheckbox = _enumCheckbox;
@synthesize browseButton = _browseButton;
@synthesize pathTextField = _pathTextField;
@synthesize searchButton = _searchButton;
@synthesize exportButton = _exportButton;
@synthesize searchDirectoryPath = _searchDirectoryPath;

// Constant strings
NSString const *kSettingControlKey = @"kSettingControlKey";
NSString const *kSettingExtensionKey = @"kSettingExtensionKey";


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Setup the results array
    _results = [[NSMutableArray alloc] init];
    
    // Setup the retina images array
    _retinaImagePaths = [[NSMutableArray alloc] init];
    
    // Setup the queue
    _queue = [[NSOperationQueue alloc] init];
    
    // Setup double click
    [_resultsTableView setDoubleAction:@selector(tableViewDoubleClicked)];
    
    // Setup labels
    [_statusLabel setTextColor:[NSColor lightGrayColor]];
    
    // Setup search button
    [_searchButton setBezelStyle:NSRoundedBezelStyle];
    [_searchButton setKeyEquivalent:@"\r"];

	_fileData = [NSMutableDictionary new];
	_fileDataLock = [NSLock new];
}

- (void)dealloc {
    [_searchDirectoryPath release];
    [_pngFiles release];
    [_results release];
    [_retinaImagePaths release];
    [_queue release];
    
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)browseButtonSelected:(id)sender {
    // Show an open panel
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    BOOL okButtonPressed = [openPanel runModal] == NSModalResponseOK;
    if (okButtonPressed) {
        // Store the path
        self.searchDirectoryPath = [[openPanel directoryURL] path];
        
        // Update the path text field
        [self.pathTextField setStringValue:self.searchDirectoryPath];
    }
}

- (IBAction)exportButtonSelected:(id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    [save setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    
	BOOL okButtonPressed = [save runModal] == NSModalResponseOK;
    if (okButtonPressed) {
        NSString *selectedFile = [[save URL] path];
        
        NSMutableString *outputResults = [[NSMutableString alloc] init];
        [outputResults appendFormat:NSLocalizedString(@"ExportSummaryTitle", @""), self.searchDirectoryPath];
        
        for (NSString *path in _results) {
            [outputResults appendFormat:@"%@\n",path];
        }
        
        // Output
        [outputResults writeToFile:selectedFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [outputResults release];
    }
}

- (IBAction)startSearch:(id)sender {
    // Check if user has selected or entered a path
	NSString *projectPath = [self.pathTextField stringValue];
	BOOL isPathEmpty = [projectPath isEqualToString:@""];
    if (isPathEmpty) {
        // Show an alert
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:NSLocalizedString(@"ProjectPathErrorTitle", @"")];
        [alert setInformativeText:NSLocalizedString(@"PleaseSelectValidPathErrorMessage", @"")];
        [alert runModal];
        
        return;
    }
    
    // Check the path exists
	BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:projectPath];
    if (!pathExists) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:NSLocalizedString(@"ProjectPathErrorTitle", @"")];
        [alert setInformativeText:NSLocalizedString(@"InvalidFolderPathErrorMessage", @"")];
        [alert runModal];
        
        return;
    }
    
	// user has entered a path instead of browsing for one
	if (!self.searchDirectoryPath && ![self.searchDirectoryPath isEqualToString:@""]) {
		self.searchDirectoryPath = projectPath;
	}

    // Change the button text
    [_searchButton setEnabled:NO];
    [_searchButton setKeyEquivalent:@""];
    
    // Reset
    [_results removeAllObjects];
    [_retinaImagePaths removeAllObjects];
    [_resultsTableView reloadData];
    
    // Start the search
    NSInvocationOperation *searchOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runImageSearch) object:nil];
    [_queue addOperation:searchOperation];
    [searchOperation release];
    
    isSearching = YES;
}

- (void)runImageSearch {
    // Start the ui
    [self setUIEnabled:NO];
    
    // Find all the .png files in the folder
    [_pngFiles release];
    _pngFiles = [[self pngFilesAtDirectory:_searchDirectoryPath] retain];
    
    NSArray *pngFiles = _pngFiles;

	BOOL filterEnumVariables = [_enumCheckbox state];
    if (filterEnumVariables) {
        NSMutableArray *mutablePngFiles = [NSMutableArray arrayWithArray:pngFiles];
        
        // Trying to filter image names like: "Section_0.png", "Section_1.png", etc (these names can possibly be created by [NSString stringWithFormat:@"Section_%d", (int)] constructions) to just "Section_" item
        for (NSInteger index = 0, count = [mutablePngFiles count]; index < count; index++) {
            NSString *imageName = [mutablePngFiles objectAtIndex:index];
            NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[_-].*\\d.*.png" options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *newImageName = [regExp stringByReplacingMatchesInString:imageName options:NSMatchingReportProgress range:NSMakeRange(0, [imageName length]) withTemplate:@""];
			if (newImageName) {
                [mutablePngFiles replaceObjectAtIndex:index withObject:newImageName];
			}
        }
        
        // Remove duplicates and update pngFiles array
        pngFiles = [[NSSet setWithArray:mutablePngFiles] allObjects];
    }
    
    // Setup all the @2x image firstly
    for (NSString *pngPath in _pngFiles) {
        NSString *imageName = [pngPath lastPathComponent];
        
        // Does the image have a @2x
        NSRange retinaRange = [imageName rangeOfString:@"@2x"];
        if (retinaRange.location != NSNotFound) {
            // Add to retina image paths
            [_retinaImagePaths addObject:pngPath];
        }
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Now loop and check
    [pngFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_group_async(group, queue, ^{
            NSString *pngPath = (NSString *)obj;
            
			BOOL pngPathEmpty = [pngPath isEqualToString:@""];
            if (!pngPathEmpty) {
                // Grab the file name
                NSString *imageName = [pngPath lastPathComponent];
                
                // Check that it's not a @2x or reserved image name
				BOOL isValidImage = [self isValidImageAtPath:pngPath];
                if (isValidImage) {
                    
                    // Settings items
                    NSArray *settingsItems = [NSArray arrayWithObjects:
                                              [NSDictionary dictionaryWithObjectsAndKeys:_mCheckbox, kSettingControlKey, @"m", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_xibCheckbox, kSettingControlKey, @"xib", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_sbCheckbox, kSettingControlKey, @"storyboard", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_cppCheckbox, kSettingControlKey, @"cpp", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_mmCheckbox, kSettingControlKey, @"mm", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_htmlCheckbox, kSettingControlKey, @"html", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_cssCheckbox, kSettingControlKey, @"css", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_plistCheckbox, kSettingControlKey, @"plist", kSettingExtensionKey, nil],
                                              [NSDictionary dictionaryWithObjectsAndKeys:_headerCheckbox, kSettingControlKey, @"h", kSettingExtensionKey, nil],
                                              nil];

                    BOOL isSearchCancelled = NO;
                    for (NSDictionary *settingDic in settingsItems) {
                        // Get the items
                        id checkbox = [settingDic objectForKey:kSettingControlKey];
                        NSString *extension = [settingDic objectForKey:kSettingExtensionKey];
                        
                        // Run the check
                        if (!isSearchCancelled && [checkbox state] &&
                           [self occurancesOfImageNamed:imageName atDirectory:_searchDirectoryPath inFileExtensionType:extension]) {
                            isSearchCancelled = YES;
                        }
                    }
                    
                    // Is it not found
                    // Update results
                    if (!isSearchCancelled)
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addNewResult:pngPath];
                        });
                }
            }
        });
    }];

    dispatch_group_notify(group, queue, ^{
                              dispatch_async(dispatch_get_main_queue(), ^{
                                                 // Sorting results and refreshing table
                                                 [_results sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                                                 [_resultsTableView reloadData];
                                                 
                                                 // Calculate how much file size we saved and update the label
                                                 int fileSize = 0;
                                                 for (NSString *path in _results) {
                                                     fileSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
                                                 }
                                                 
                                                 [_statusLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"CompletedResultMessage", @""), (unsigned long)[_results count], [self stringFromFileSize:fileSize]]];
                                                 
                                                 // Enable the ui
                                                 [self setUIEnabled:YES];
                                                 
                                                 isSearching = NO;
                                                 [_fileData removeAllObjects];
                                             });
                          });
}

- (void)setUIEnabled:(BOOL)state {
    // Individual
    if (state) {
        [_searchButton setTitle:NSLocalizedString(@"Search", @"")];
        [_searchButton setKeyEquivalent:@"\r"];
        [_processIndicator stopAnimation:self];
    } else {
        [_processIndicator startAnimation:self];
        [_statusLabel setStringValue:NSLocalizedString(@"Searching", @"")];
    }
    
    // Button groups
    [_searchButton setEnabled:state];
    [_processIndicator setHidden:state];
    [_mCheckbox setEnabled:state];
    [_xibCheckbox setEnabled:state];
    [_sbCheckbox setEnabled:state];
    [_cppCheckbox setEnabled:state];
    [_mmCheckbox setEnabled:state];
    [_headerCheckbox setEnabled:state];
    [_htmlCheckbox setEnabled:state];
    [_plistCheckbox setEnabled:state];
    [_cssCheckbox setEnabled:state];
    [_browseButton setEnabled:state];
    [_pathTextField setEnabled:state];
    [_exportButton setHidden:!state];
}

- (NSArray *)pngFilesAtDirectory:(NSString *)directoryPath {
    // Create a find task
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath: @"/usr/bin/find"];
    
    // Search for all png files
    NSArray *argvals = [NSArray arrayWithObjects:directoryPath,@"-name",@"*.png", nil];
    [task setArguments: argvals];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    // Read the response
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    
    // See if we can create a lines array
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    return lines;
}

- (BOOL)isValidImageAtPath:(NSString *)imagePath {
    NSString *imageName = [imagePath lastPathComponent];
    NSRange retinaRange = [imageName rangeOfString:@"@2x"];
	BOOL has2xImage = retinaRange.location != NSNotFound;
	BOOL isThirdPartyBundle = [imagePath rangeOfString:@".bundle"].length > 0;
	BOOL isNamedDefault = [imageName isEqualToString:@"Default.png"];
	BOOL isNamedIcon = [imageName isEqualToString:@"Icon.png"] || [imageName isEqualToString:@"Icon@2x.png"] || [imageName isEqualToString:@"Icon-72.png"];
	BOOL isUniversalImage = [imagePath rangeOfString:@"~ipad" options:NSCaseInsensitiveSearch].length > 0;

    return has2xImage && isThirdPartyBundle && isNamedDefault && isNamedIcon && isUniversalImage;
}

- (int)occurancesOfImageNamed:(NSString *)imageName atDirectory:(NSString *)directoryPath inFileExtensionType:(NSString *)extension {
	[_fileDataLock lock];
	
	NSData *data = [_fileData objectForKey:directoryPath];
	if (!data) {
		NSTask *task = [[[NSTask alloc] init] autorelease];
		[task setLaunchPath: @"/bin/sh"];
		
		// Setup the call
		NSString *cmd = [NSString stringWithFormat:@"for filename in `find %@ -name '*.%@'`; do cat $filename 2>/dev/null | grep -o %@ ; done", directoryPath, extension, [imageName stringByDeletingPathExtension]];
        NSLog(@"%@", cmd);
		NSArray *argvals = [NSArray arrayWithObjects: @"-c", cmd, nil];
		[task setArguments: argvals];
		
		NSPipe *pipe = [NSPipe pipe];
		[task setStandardOutput: pipe];
		[task launch];
		
		// Read the response
		NSFileHandle *file = [pipe fileHandleForReading];
		data = [file readDataToEndOfFile];
        NSString *key = [NSString stringWithFormat:@"%@/%@",directoryPath, imageName];
		
		[_fileData setObject:data forKey:key];
	}

	[_fileDataLock unlock];
    
    NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    // Calculate the count
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
    int count = 0;
    while ([scanner scanUpToCharactersFromSet:newline intoString:nil]) {
        count++;
    }
    
    return count;
}

- (void)addNewResult:(NSString *)pngPath {
	BOOL imageExists = [_pngFiles indexOfObject:pngPath] != NSNotFound;
	if (!imageExists) {
        return;
	}

    // Add and reload
    [_results addObject:pngPath];
    
    // Check for an @2x image too!
    for (NSString *retinaPath in _retinaImagePaths) {
        
        // Compare the image name and the retina image name
        NSString *imageName = [pngPath lastPathComponent];
        imageName = [imageName stringByDeletingPathExtension];
        NSString *retinaImageName = [retinaPath lastPathComponent];
        retinaImageName = [retinaImageName stringByDeletingPathExtension];
        retinaImageName = [retinaImageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        
        // Check
        if([imageName isEqualToString:retinaImageName]) {
            // Add it
            [_results addObject:retinaPath];
            
            break;
        }
    }
    
    // Reload
    [_resultsTableView reloadData];
    
    // Scroll to the bottom
    NSInteger numberOfRows = [_resultsTableView numberOfRows];
	if (numberOfRows > 0) {
        [_resultsTableView scrollRowToVisible:numberOfRows - 1];
	}
}

#pragma mark - NSTableView Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_results count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    // Get the unused image
    NSString *pngPath = [_results objectAtIndex:rowIndex];
    
    // Check the column
    if ([[tableColumn identifier] isEqualToString:@"ImageIcon"]) {
        return [[[NSImage alloc] initByReferencingFile:pngPath] autorelease];
    } else if ([[tableColumn identifier] isEqualToString:@"ImageShortName"]) {
        return [pngPath lastPathComponent];
    }
    
    return pngPath;
}

- (void)tableViewDoubleClicked {
    // Open finder
    NSString *path = [_results objectAtIndex:[_resultsTableView clickedRow]];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}

- (NSString *)stringFromFileSize:(int)fileSize {
	if (fileSize < 1023) {
		return([NSString stringWithFormat:@"%i bytes", fileSize]);
	}

	float floatSize = fileSize / 1024;
	if (floatSize < 1023) {
		return([NSString stringWithFormat:@"%1.1f KB", floatSize]);
	}

	floatSize = floatSize / 1024;
	if (floatSize < 1023) {
		return([NSString stringWithFormat:@"%1.1f MB", floatSize]);
	}
    
	floatSize = floatSize / 1024;
	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

@end
