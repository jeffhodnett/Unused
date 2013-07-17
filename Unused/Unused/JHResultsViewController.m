//
//  JHResultsViewController.m
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import "JHResultsViewController.h"
#import "JHUnusedScanManager.h"

@interface JHResultsViewController ()

-(NSString *)stringFromFileSize:(int)size;

@end

@implementation JHResultsViewController

@synthesize resultsTableView=_resultsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Setup double click
    //[_resultsTableView setDoubleAction:@selector(tableViewDoubleClicked)];
    
    // Setup search button
    //[_searchButton setBezelStyle:NSRoundedBezelStyle];
    //[_searchButton setKeyEquivalent:@"\r"];
    
    _results = [[NSMutableArray alloc] init];
    
    // Become scan delegate
    [[JHUnusedScanManager sharedManager] setDelegate:self];
}

#pragma mark - Actions
-(IBAction)startSearch:(id)sender
{
    // Start
    [[JHUnusedScanManager sharedManager] startScan];
}

-(IBAction)exportButtonSelected:(id)sender
{
//    NSSavePanel *save = [NSSavePanel savePanel];
//    [save setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
//    NSInteger result = [save runModal];
//    
//    if (result == NSOKButton) {
//        NSString *selectedFile = [[save URL] path];
//        
//        NSMutableString *outputResults = [[NSMutableString alloc] init];
//        [outputResults appendFormat:NSLocalizedString(@"ExportSummaryTitle", @""), self.searchDirectoryPath];
//        
//        for (NSString *path in _results) {
//            [outputResults appendFormat:@"%@\n",path];
//        }
//        
//        // Output
//        [outputResults writeToFile:selectedFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        
//        [outputResults release];
//    }
}

#pragma mark - Scan Manager Delegate methods
-(void)scanManager:(JHUnusedScanManager *)manager didFindResult:(NSString *)result
{
    NSLog(@"got result %@",result);
    
    // Reload
    [_results addObject:result];
    [_resultsTableView reloadData];

    // Scroll to the bottom
    NSInteger numberOfRows = [_resultsTableView numberOfRows];
    if (numberOfRows > 0)
        [_resultsTableView scrollRowToVisible:numberOfRows - 1];
}

-(void)scanManager:(JHUnusedScanManager *)manager finishedScanWithResults:(NSArray *)results
{
    // Calculate how much file size we saved and update the label
    int fileSize = 0;
    for (NSString *path in _results) {
        fileSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
    
    NSLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"CompletedResultMessage", @""), (unsigned long)[_results count], [self stringFromFileSize:fileSize]]);
    
    //                                                 [_statusLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"CompletedResultMessage", @""), (unsigned long)[_results count], [self stringFromFileSize:fileSize]]];
    

}

#pragma mark - NSTableView Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_results count];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
    // Get the unused image
    NSString *pngPath = [_results objectAtIndex:rowIndex];
    
    // Check the column
    if ([[tableColumn identifier] isEqualToString:@"ImageIcon"])
    {
        // Return an image object
        NSImage *img = [[[NSImage alloc] initByReferencingFile:pngPath] autorelease];
        return img;
    }
    else if ([[tableColumn identifier] isEqualToString:@"ImageShortName"])
    {
        NSString *imageName = [pngPath lastPathComponent];
        return imageName;
    }
    
    return pngPath;
}

#pragma mark - NSTableView Delegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString *pngPath = [_results objectAtIndex:row];
    NSImage *img = [[[NSImage alloc] initByReferencingFile:pngPath] autorelease];
    
    const float maxSize = 100.0f;
    float imageHeight = img.size.height;
    if(imageHeight < maxSize) {
        return imageHeight;
    }
    
    return maxSize;
}

-(void)tableViewDoubleClicked
{
    // Open finder
    NSString *path = [_results objectAtIndex:[_resultsTableView clickedRow]];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}

#pragma mark - Helpers
- (NSString *)stringFromFileSize:(int)size
{
	float floatSize = size;
	if (size<1023)
		return([NSString stringWithFormat:@"%i bytes", size]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB", floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB", floatSize]);
	floatSize = floatSize / 1024;
    
	// Add as many as you like
    
	return ([NSString stringWithFormat:@"%1.1f GB", floatSize]);
}

@end
