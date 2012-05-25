//
//  UnusedAppDelegate.m
//  Unused
//
//  Created by Jeff Hodnett on 19/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UnusedAppDelegate.h"

@implementation UnusedAppDelegate

@synthesize resultsTableView;
@synthesize processIndicator;
@synthesize statusLabel;
@synthesize window;
@synthesize mCheckbox;
@synthesize xibCheckbox;
@synthesize cppCheckbox;
@synthesize mmCheckbox;
@synthesize searchDirectoryPath;
@synthesize browseButton;
@synthesize pathTextField;
@synthesize searchButton;
@synthesize exportButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // Setup the results array
    results = [[NSMutableArray alloc] init];
    
    // Setup the retina images array
    retinaImagePaths = [[NSMutableArray alloc] init];
    
    // Setup the queue
    queue = [[NSOperationQueue alloc] init];
    
    // Setup double click
    [resultsTableView setDoubleAction:@selector(tableViewDoubleClicked)];
    
    // Setup labels
    [statusLabel setTextColor:[NSColor lightGrayColor]];

    // Setup search button
    [searchButton setBezelStyle:NSRoundedBezelStyle];
    [searchButton setKeyEquivalent:@"\r"];
}

-(void)dealloc
{
    [searchDirectoryPath release];
    [results release];
    [retinaImagePaths release];
    [queue release];    

    [super dealloc];
}

#pragma mark - Actions
-(IBAction)browseButtonSelected:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];

    NSInteger option = [openPanel runModal];
    
    if (option == NSOKButton) {
        self.searchDirectoryPath = [openPanel directory];
        
        // Update the path text field
        [self.pathTextField setStringValue:self.searchDirectoryPath];
    }
}

-(IBAction)exportButtonSelected:(id)sender
{
    NSSavePanel *save = [NSSavePanel savePanel];
    [save setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    NSInteger result = [save runModal];
    
    if (result == NSOKButton) {
        NSString *selectedFile = [save filename];
        
        NSMutableString *outputResults = [[NSMutableString alloc] init];
        [outputResults appendFormat:@"Unused Files in project %@\n\n",self.searchDirectoryPath];
        
        for (NSString *path in results) {
            [outputResults appendFormat:@"%@\n",path];
        }
        
        // Output
        [outputResults writeToFile:selectedFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [outputResults release];
    }
}

-(IBAction)startSearch:(id)sender
{    
    // Check for a path
    if(!self.searchDirectoryPath) {
        // Show an alert
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@"Project Path Error"];
        [alert setInformativeText:@"Please select a valid project folder!"];
        [alert runModal];
        
        return;
    }
    
    // Check the path
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.searchDirectoryPath]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@"Project Path Error"];
        [alert setInformativeText:@"Path is not valid!! Please select a valid project folder!"];
        [alert runModal];
        
        return;        
    }
    
    // Change the button text
//    [searchButton setTitle:@"Cancel"];
//    [searchButton setKeyEquivalent:@""];
    [searchButton setEnabled:NO];
    [searchButton setKeyEquivalent:@""];
    
    // Reset
    [results removeAllObjects];
    [retinaImagePaths removeAllObjects];
    [resultsTableView reloadData];
    
    // Start the search
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runImageSearch) object:nil];
    [queue addOperation:op];
    [op release];
    
    isSearching = YES;
}

-(void)runImageSearch
{
    // Start the ui
    [self setUIEnabled:NO];
    
    // Find all the .png files in the folder
    NSArray *pngFiles = [self pngFilesAtDirectory:searchDirectoryPath];

    // Setup all the @2x image firstly
    for (NSString *pngPath in pngFiles) {
        NSString *imageName = [pngPath lastPathComponent];
        
        // Does the image have a @2x
        NSRange retinaRange = [imageName rangeOfString:@"@2x"];
        if(retinaRange.location != NSNotFound) {
            // Add to retina image paths
            [retinaImagePaths addObject:pngPath];
        }
    }
    
    // Now loop and check
    for (NSString *pngPath in pngFiles) {
        
        // Check that the png path is not empty
        if(![pngPath isEqualToString:@""]) {
            // Grab the file name
            NSString *imageName = [pngPath lastPathComponent];
                        
            // Check that it's not a @2x or reserved image name
            if([self isValidImageAtPath:pngPath]) {
                
                // Run the checks
                int count = 0;
                BOOL found = NO;
                if([mCheckbox state]) {
                    count += [self occurancesOfImageNamed:imageName atDirectory:searchDirectoryPath inFileExtensionType:@"m"];
                }
                if(count > 0) {
                    found = YES;
                }
                
                if(!found && [xibCheckbox state]) {
                    count += [self occurancesOfImageNamed:imageName atDirectory:searchDirectoryPath inFileExtensionType:@"xib"];
                }
                if(count > 0) {
                    found = YES;
                }

                if(!found && [cppCheckbox state]) {
                    count += [self occurancesOfImageNamed:imageName atDirectory:searchDirectoryPath inFileExtensionType:@"cpp"];
                }
                if(count > 0) {
                    found = YES;
                }
                
                if(!found && [mmCheckbox state]) {
                    count += [self occurancesOfImageNamed:imageName atDirectory:searchDirectoryPath inFileExtensionType:@"mm"];
                }
                if(count > 0) {
                    found = YES;
                }
                
                // Is it not found
                if(count == 0) {                    
                    // Update results
                    [self addNewResult:pngPath];
                }
            }
            
        }
    }
    
    // Calculate how much file size we saved and update the label
    int fileSize = 0;
    for (NSString *path in results) {
        fileSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
        
    [statusLabel setStringValue:[NSString stringWithFormat:@"Completed - Found %d - Size %@", [results count], [self stringFromFileSize:fileSize]]];
    
    // Enable the ui
    [self setUIEnabled:YES];
    
    isSearching = NO;
}

-(void)setUIEnabled:(BOOL)state
{
    if(state) {
        [searchButton setTitle:@"Search"];
        [searchButton setKeyEquivalent:@"\r"];
        [searchButton setEnabled:YES];
        [processIndicator setHidden:YES];
        [processIndicator stopAnimation:self];
        [mCheckbox setEnabled:YES];
        [xibCheckbox setEnabled:YES];
        [cppCheckbox setEnabled:YES];
        [mmCheckbox setEnabled:YES];
        [browseButton setEnabled:YES];
        [pathTextField setEnabled:YES];
        [exportButton setHidden:NO];   
    }
    else {
        [processIndicator setHidden:NO];
        [processIndicator startAnimation:self];
        [statusLabel setStringValue:@"Searching..."];
        [mCheckbox setEnabled:NO];
        [xibCheckbox setEnabled:NO];
        [cppCheckbox setEnabled:NO];
        [mmCheckbox setEnabled:NO];
        [browseButton setEnabled:NO];
        [pathTextField setEnabled:NO];
        [exportButton setHidden:YES];
    }
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
    
    // Is the name is Default
    if([imageName isEqualToString:@"Default.png"]) {
        return NO;
    }
    
    // Is the name Icon
    if([imageName isEqualToString:@"Icon.png"] || [imageName isEqualToString:@"Icon@2x.png"] || [imageName isEqualToString:@"Icon-72.png"]) {
        return NO;
    }
    
    return YES;
}

-(int)occurancesOfImageNamed:(NSString *)imageName atDirectory:(NSString *)directoryPath inFileExtensionType:(NSString *)extension
{
    NSTask *task;
    task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath: @"/usr/bin/find"];

    // Setup the call
    NSArray *argvals = [NSArray arrayWithObjects:directoryPath,@"-name",[NSString stringWithFormat:@"*.%@",extension],@"-exec",@"grep",@"-li",imageName, @"{}", @";",nil];
    [task setArguments: argvals];    
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    // Read the response
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    
//    NSLog (@"script returned:\n%@", string);
    
    // See if we can create a lines array
//    NSArray *lines = [string componentsSeparatedByString:@"\n"];
//    NSLog(@"lines= %@",lines);
    
    // Calculate the count
    NSScanner *scanner = [NSScanner scannerWithString: string];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    int count = 0;
    while ([scanner scanUpToCharactersFromSet: whiteSpace  intoString: nil]) {
        count++;
    }
//    NSLog(@"count = %d",count);
    
    return count;
}

-(void)addNewResult:(NSString *)pngPath
{
    // Add and reload
    [results addObject:pngPath];
    
    // Check for an @2x image too!
    for (NSString *retinaPath in retinaImagePaths) {
        
        // Compare the image name and the retina image name
        NSString *imageName = [pngPath lastPathComponent];
        imageName = [imageName stringByDeletingPathExtension];
        NSString *retinaImageName = [retinaPath lastPathComponent];
        retinaImageName = [retinaImageName stringByDeletingPathExtension];
        retinaImageName = [retinaImageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        
        // Check
        if([imageName isEqualToString:retinaImageName]) {
            // Add it
            [results addObject:retinaPath];
            
            break;
        }
    }
    
    // Reload
    [resultsTableView reloadData];
        
    // Scroll to the bottom
    NSInteger numberOfRows = [resultsTableView numberOfRows];
    if (numberOfRows > 0)
        [resultsTableView scrollRowToVisible:numberOfRows - 1];
}

#pragma mark - NSTableView Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [results count];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
    NSString *pngPath = [results objectAtIndex:rowIndex];
    
    if ([[tableColumn identifier] isEqualToString:@"shortName"])
    {
        NSString *imageName = [pngPath lastPathComponent];
        return imageName;
    }

    return pngPath;
}

-(void)tableViewDoubleClicked
{
    // Open finder
    NSString *path = [results objectAtIndex:[resultsTableView clickedRow]];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];

//    [[NSWorkspace sharedWorkspace] openFile:@"/Myfiles/README" withApplication:@"Edit"]; 
//    [[NSWorkspace sharedWorkspace] openFile:path];
//    [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Xcode"];
    
//    NSString* scriptString = [NSString stringWithFormat: @"tell application \"Finder\" to open posix file \"%@\"", path]; 
//    NSAppleScript* script = [[NSAppleScript alloc] initWithSource: scriptString]; 
//    NSDictionary* errorDict = nil; 
//    [script executeAndReturnError: &errorDict]; 
//    [script release]; 
    
    
}

- (NSString *)stringFromFileSize:(int)theSize
{
	float floatSize = theSize;
	if (theSize<1023)
		return([NSString stringWithFormat:@"%i bytes",theSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;
    
	// Add as many as you like
    
	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

@end
