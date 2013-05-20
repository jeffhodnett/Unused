//
//  JHUnusedScanManager.m
//  Unused
//
//  Created by Jeff Hodnett on 5/17/13.
//
//

#import "JHUnusedScanManager.h"

#define SHOULD_FILTER_ENUM_VARIANTS YES

// Constant strings
NSString const *kSettingControlKey = @"kSettingControlKey";
NSString const *kSettingExtensionKey = @"kSettingExtensionKey";

@implementation JHUnusedScanManager

+ (id)sharedManager
{
    static JHUnusedScanManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        
         // Setup the results array
         _results = [[NSMutableArray alloc] init];
         
         // Setup the retina images array
         _retinaImagePaths = [[NSMutableArray alloc] init];
         
         // Setup the queue
         _queue = [[NSOperationQueue alloc] init];
        
        // Setup lock
         _fileData = [NSMutableDictionary new];
         _fileDataLock = [NSLock new];
    }
    return self;
}

-(void)dealloc
{
    // Never ever say never ever - MacGruber
    
    [super dealloc];
}

#pragma mark - Actions
-(IBAction)browseButtonSelected:(id)sender
{
    // Show an open panel
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    NSInteger option = [openPanel runModal];
    if (option == NSOKButton) {
        // Store the path
        //        self.searchDirectoryPath = [[openPanel directoryURL] path];
    }
}

-(IBAction)startSearch:(id)sender
{
    // Check for a path
//    if(!self.searchDirectoryPath) {
//        // Show an alert
//        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
//        [alert setMessageText:NSLocalizedString(@"ProjectPathErrorTitle", @"")];
//        [alert setInformativeText:NSLocalizedString(@"PleaseSelectValidPathErrorMessage", @"")];
//        [alert runModal];
//        
//        return;
//    }
    
    // Check the path
//    if(![[NSFileManager defaultManager] fileExistsAtPath:self.searchDirectoryPath]) {
//        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
//        [alert setMessageText:NSLocalizedString(@"ProjectPathErrorTitle", @"")];
//        [alert setInformativeText:NSLocalizedString(@"InvalidFolderPathErrorMessage", @"")];
//        [alert runModal];
//        
//        return;
//    }
    
    // Reset
    [_results removeAllObjects];
    [_retinaImagePaths removeAllObjects];
    
    // Start the search
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runImageSearch) object:nil];
    [_queue addOperation:op];
    [op release];
    
    isSearching = YES;
}

-(void)runImageSearch
{
    // Find all the .png files in the folder
    [_pngFiles release];
    _pngFiles = [[self pngFilesAtDirectory:_searchDirectoryPath] retain];
    
    NSArray *pngFiles = _pngFiles;
    
    if (SHOULD_FILTER_ENUM_VARIANTS)
    {
        NSMutableArray *mutablePngFiles = [NSMutableArray arrayWithArray:pngFiles];
        
        // Trying to filter image names like: "Section_0.png", "Section_1.png", etc (these names can possibly be created by [NSString stringWithFormat:@"Section_%d", (int)] constructions) to just "Section_" item
        for (NSInteger index = 0, count = [mutablePngFiles count]; index < count; index++)
        {
            NSString *imageName = [mutablePngFiles objectAtIndex:index];
            NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[_-].*\\d.*.png" options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *newImageName = [regExp stringByReplacingMatchesInString:imageName options:NSMatchingReportProgress range:NSMakeRange(0, [imageName length]) withTemplate:@""];
            if (newImageName != nil)
                [mutablePngFiles replaceObjectAtIndex:index withObject:newImageName];
        }
        
        // Remove duplicates and update pngFiles array
        pngFiles = [[NSSet setWithArray:mutablePngFiles] allObjects];
    }
    
    // Setup all the @2x image firstly
    for (NSString *pngPath in _pngFiles) {
        NSString *imageName = [pngPath lastPathComponent];
        
        // Does the image have a @2x
        NSRange retinaRange = [imageName rangeOfString:@"@2x"];
        if(retinaRange.location != NSNotFound) {
            // Add to retina image paths
            [_retinaImagePaths addObject:pngPath];
        }
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Now loop and check
    [pngFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         dispatch_group_async(group, queue, ^
                              {
                                  NSString *pngPath = (NSString *)obj;
                                  
                                  // Check that the png path is not empty
                                  if(![pngPath isEqualToString:@""]) {
                                      // Grab the file name
                                      NSString *imageName = [pngPath lastPathComponent];
                                      
                                      // Check that it's not a @2x or reserved image name
                                      if([self isValidImageAtPath:pngPath]) {
                                          
                                          // Settings items
//                                          NSArray *settingsItems = [NSArray arrayWithObjects:
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_mCheckbox, kSettingControlKey, @"m", kSettingExtensionKey, nil],
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_xibCheckbox, kSettingControlKey, @"xib", kSettingExtensionKey, nil],
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_cppCheckbox, kSettingControlKey, @"cpp", kSettingExtensionKey, nil],
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_mmCheckbox, kSettingControlKey, @"mm", kSettingExtensionKey, nil],
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_htmlCheckbox, kSettingControlKey, @"html", kSettingExtensionKey, nil],
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_cssCheckbox, kSettingControlKey, @"css", kSettingExtensionKey, nil],
//                                                                    [NSDictionary dictionaryWithObjectsAndKeys:_plistCheckbox, kSettingControlKey, @"plist", kSettingExtensionKey, nil],
//                                                                    
//                                                                    nil];
                                          NSArray *settingsItems = [NSArray array];
                                          BOOL isSearchCancelled = NO;
                                          for (NSDictionary *settingDic in settingsItems) {
                                              // Get the items
                                              id checkbox = [settingDic objectForKey:kSettingControlKey];
                                              NSString *extension = [settingDic objectForKey:kSettingControlKey];
                                              
                                              // Run the check
                                              if(!isSearchCancelled && [checkbox state] &&
                                                 [self occurancesOfImageNamed:imageName atDirectory:_searchDirectoryPath inFileExtensionType:extension]) {
                                                  isSearchCancelled = YES;
                                              }
                                          }
                                          
                                          // Is it not found
                                          // Update results
                                          if (!isSearchCancelled)
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 [self addNewResult:pngPath];
                                                             });
                                      }
                                  }
                              });
     }];
    
    dispatch_group_notify(group, queue, ^
                          {
                              dispatch_async(dispatch_get_main_queue(), ^
                                             {
                                                 // Sorting results and refreshing table
                                                 [_results sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                                                 
                                                 // Calculate how much file size we saved and update the label
                                                 int fileSize = 0;
                                                 for (NSString *path in _results) {
                                                     fileSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
                                                 }
                                                 
//                                                 [_statusLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"CompletedResultMessage", @""), (unsigned long)[_results count], [self stringFromFileSize:fileSize]]];
                                                 
                                                 // Enable the ui
//                                                 [self setUIEnabled:YES];
                                                 
                                                 isSearching = NO;
                                                 [_fileData removeAllObjects];
                                             });
                          });
}

-(NSArray *)pngFilesAtDirectory:(NSString *)directoryPath
{
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

-(BOOL)isValidImageAtPath:(NSString *)imagePath
{
    NSString *imageName = [imagePath lastPathComponent];
    
    // Does the image have a @2x
    NSRange retinaRange = [imageName rangeOfString:@"@2x"];
    if(retinaRange.location != NSNotFound) {
        return NO;
    }
    
    // Is the name a part of 3rd party bundle
    if([imagePath rangeOfString:@".bundle"].length > 0) {
        return NO;
    }
    
    // Is the name is Default
    if([imageName isEqualToString:@"Default.png"]) {
        return NO;
    }
    
    // Is the name Icon
    if([imageName isEqualToString:@"Icon.png"] || [imageName isEqualToString:@"Icon@2x.png"] || [imageName isEqualToString:@"Icon-72.png"]) {
        return NO;
    }
    
    // Is it a universal image
    if([imagePath rangeOfString:@"~ipad" options:NSCaseInsensitiveSearch].length > 0) {
        return NO;
    }
    
    return YES;
}

-(int)occurancesOfImageNamed:(NSString *)imageName atDirectory:(NSString *)directoryPath inFileExtensionType:(NSString *)extension
{
    NSData *data;
	[_fileDataLock lock];
	data = [_fileData objectForKey:directoryPath];
	
	if (data == nil)
	{
		NSTask *task;
		task = [[[NSTask alloc] init] autorelease];
		[task setLaunchPath: @"/bin/sh"];
		
		// Setup the call
		NSString *cmd = [NSString stringWithFormat:@"export IFS=""; while read file; do cat $file | grep -o %@ ; done <<< $(find %@ -name *.%@)", [imageName stringByDeletingPathExtension], directoryPath, extension];
		NSArray *argvals = [NSArray arrayWithObjects: @"-c", cmd, nil];
		[task setArguments: argvals];
		
		NSPipe *pipe;
		pipe = [NSPipe pipe];
		[task setStandardOutput: pipe];
		
		NSFileHandle *file;
		file = [pipe fileHandleForReading];
		
		[task launch];
		
		// Read the response
		data = [file readDataToEndOfFile];
		
		[_fileData setObject:data forKey:directoryPath];
	}
	[_fileDataLock unlock];
    
    NSString *string;
    string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    
    // Calculate the count
    NSScanner *scanner = [NSScanner scannerWithString: string];
    NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
    int count = 0;
    while ([scanner scanUpToCharactersFromSet: newline  intoString: nil]) {
        count++;
    }
    
    return count;
}

-(void)addNewResult:(NSString *)pngPath
{
    if ([_pngFiles indexOfObject:pngPath] == NSNotFound)
        return;
    
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
    
//    // Reload
//    [_resultsTableView reloadData];
//    
//    // Scroll to the bottom
//    NSInteger numberOfRows = [_resultsTableView numberOfRows];
//    if (numberOfRows > 0)
//        [_resultsTableView scrollRowToVisible:numberOfRows - 1];
}


@end
