//
//  UnusedAppDelegate.m
//  Unused
//  https://github.com/jeffhodnett/Unused
//
//  Copyright (c) 2015 Jeff Hodnett
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "UnusedAppDelegate.h"
#import "Searcher.h"
#import "FileUtil.h"

@interface UnusedAppDelegate () <SearcherDelegate>

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) Searcher *searcher;

// Handle the ui updates
- (void)setUIEnabled:(BOOL)state;

@end

// Constant strings
static NSString *const kTableColumnImageIcon = @"ImageIcon";
static NSString *const kTableColumnImageShortName = @"ImageShortName";

@implementation UnusedAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Setup the results array
    _results = [[NSMutableArray alloc] init];
    
    // Setup double click
    [_resultsTableView setDoubleAction:@selector(tableViewDoubleClicked)];
    
    // Setup labels
    [_statusLabel setTextColor:[NSColor lightGrayColor]];
    
    // Setup search button
    [_searchButton setBezelStyle:NSRoundedBezelStyle];
    [_searchButton setKeyEquivalent:@"\r"];

    // Setup the searcher
    self.searcher = [[Searcher alloc] init];
    self.searcher.delegate = self;
}

#pragma mark - Actions
- (IBAction)browseButtonSelected:(id)sender {
    // Show an open panel
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    if (okButtonPressed) {
        // Update the path text field
        NSString *path = [[openPanel directoryURL] path];
        [self.pathTextField setStringValue:path];
    }
}

- (IBAction)exportButtonSelected:(id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    [save setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    
	BOOL okButtonPressed = ([save runModal] == NSModalResponseOK);
    if (okButtonPressed) {
        NSString *selectedFile = [[save URL] path];
        
        NSMutableString *outputResults = [[NSMutableString alloc] init];
        NSString *projectPath = [self.pathTextField stringValue];
        [outputResults appendFormat:NSLocalizedString(@"ExportSummaryTitle", @""), projectPath];
        
        for (NSString *path in _results) {
            [outputResults appendFormat:@"%@\n",path];
        }
        
        // Output
        NSError *writeError = nil;
        [outputResults writeToFile:selectedFile atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
        
        // Check write result
        if (writeError == nil) {
            [self showAlertWithStyle:NSInformationalAlertStyle title:NSLocalizedString(@"ExportCompleteTitle", @"") subtitle:NSLocalizedString(@"ExportCompleteSubtitle", @"")];
        } else {
            NSLog(@"Unused write error:: %@", writeError);
            [self showAlertWithStyle:NSCriticalAlertStyle title:NSLocalizedString(@"ExportErrorTitle", @"") subtitle:NSLocalizedString(@"ExportErrorSubtitle", @"")];
        }
    }
}

- (IBAction)startSearch:(id)sender {
    // Check if user has selected or entered a path
	NSString *projectPath = [self.pathTextField stringValue];
	BOOL isPathEmpty = [projectPath isEqualToString:@""];
    if (isPathEmpty) {
        [self showAlertWithStyle:NSWarningAlertStyle title:NSLocalizedString(@"MissingPathErrorTitle", @"") subtitle:NSLocalizedString(@"ProjectFolderPathErrorMessage", @"")];

        return;
    }

    // Check the path exists
	BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:projectPath];
    if (!pathExists) {
        [self showAlertWithStyle:NSWarningAlertStyle title:NSLocalizedString(@"InvalidPathErrorTitle", @"") subtitle:NSLocalizedString(@"ProjectFolderPathErrorMessage", @"")];
        
        return;
    }
    
    // Reset
    [self.results removeAllObjects];
    [self.resultsTableView reloadData];
    
    // Start the ui
    [self setUIEnabled:NO];
    
    // Pass search folder
    self.searcher.projectPath = projectPath;
    
    // Pass settings
    self.searcher.mSearch = [self.mCheckbox state];
    self.searcher.xibSearch = [self.xibCheckbox state];
    self.searcher.storyboardSearch = [self.sbCheckbox state];
    self.searcher.cppSearch = [self.cppCheckbox state];
    self.searcher.headerSearch = [self.headerCheckbox state];
    self.searcher.htmlSearch = [self.htmlCheckbox state];
    self.searcher.mmSearch = [self.mmCheckbox state];
    self.searcher.plistSearch = [self.plistCheckbox state];
    self.searcher.cssSearch = [self.cssCheckbox state];
    self.searcher.swiftSearch = [self.swiftCheckbox state];
    self.searcher.enumFilter = [self.enumCheckbox state];
    
    // Start the search
    [self.searcher start];
}

#pragma mark - Helpers
- (void)showAlertWithStyle:(NSAlertStyle)style title:(NSString *)title subtitle:(NSString *)subtitle {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = style;
    [alert setMessageText:title];
    [alert setInformativeText:subtitle];
    [alert runModal];
}

- (void)scrollTableView:(NSTableView *)tableView toBottom:(BOOL)bottom {
    if (bottom) {
        NSInteger numberOfRows = [tableView numberOfRows];
        if (numberOfRows > 0) {
            [tableView scrollRowToVisible:numberOfRows - 1];
        }
    } else {
        [tableView scrollRowToVisible:0];
    }
}

- (void)setUIEnabled:(BOOL)state {
    // Individual
    if (state) {
        [_searchButton setTitle:NSLocalizedString(@"Search", @"")];
        [_searchButton setKeyEquivalent:@"\r"];
        [_processIndicator stopAnimation:self];
    } else {
        [self.searchButton setKeyEquivalent:@""];
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
    [_swiftCheckbox setEnabled:state];
    [_browseButton setEnabled:state];
    [_pathTextField setEnabled:state];
    [_exportButton setHidden:!state];
}

#pragma mark - <NSTableViewDelegate>
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.results count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    // Get the unused image
    NSString *pngPath = [self.results objectAtIndex:rowIndex];
    
    // Check the column
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:kTableColumnImageIcon]) {
        return [[NSImage alloc] initByReferencingFile:pngPath];
    } else if ([columnIdentifier isEqualToString:kTableColumnImageShortName]) {
        return [pngPath lastPathComponent];
    }
    
    return pngPath;
}

- (void)tableViewDoubleClicked {
    // Open finder
    NSString *path = [self.results objectAtIndex:[self.resultsTableView clickedRow]];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}

#pragma mark - <SearcherDelegate>
- (void)searcherDidStartSearch:(Searcher *)searcher {
}

- (void)searcher:(Searcher *)searcher didFindUnusedImage:(NSString *)imagePath {
    
    // Add and reload
    [self.results addObject:imagePath];
    
    // Reload
    [self.resultsTableView reloadData];
    
    // Scroll to the bottom
    [self scrollTableView:self.resultsTableView toBottom:YES];
}

- (void)searcher:(Searcher *)searcher didFinishSearch:(NSArray *)results {
    
    // Ensure all data is displayed
    [self.resultsTableView reloadData];
    
    // Calculate how much file size we saved and update the label
    int fileSize = 0;
    for (NSString *path in _results) {
        fileSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
    [self.statusLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"CompletedResultMessage", @""), (unsigned long)[_results count], [FileUtil stringFromFileSize:fileSize]]];
    
    // Enable the ui
    [self setUIEnabled:YES];
}

@end
