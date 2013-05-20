//
//  JHResultsViewController.m
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import "JHResultsViewController.h"

@interface JHResultsViewController ()

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

#pragma mark - NSTableView Delegate
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

-(void)tableViewDoubleClicked
{
    // Open finder
    NSString *path = [_results objectAtIndex:[_resultsTableView clickedRow]];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}


@end
