//
//  UnusedAppDelegate.h
//  Unused
//  A Mac utility to show you unused resources in your xcode projects
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

#import <Cocoa/Cocoa.h>

/**
 *  The application delegate
 */
@interface UnusedAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

// ------ Outlets ------
/**
 *  The main window
 */
@property (assign) IBOutlet NSWindow *window;

/**
 *  The results table view
 */
@property (assign) IBOutlet NSTableView *resultsTableView;

/**
 *  The loading indicator view
 */
@property (assign) IBOutlet NSProgressIndicator *processIndicator;

/**
 *  The status text label
 */
@property (assign) IBOutlet NSTextField *statusLabel;

/**
 *  The browse button
 */
@property (assign) IBOutlet NSButton *browseButton;

/**
 *  The search path text field
 */
@property (assign) IBOutlet NSTextField *pathTextField;

/**
 *  The search action button
 */
@property (assign) IBOutlet NSButton *searchButton;

/**
 *  The export button
 */
@property (assign) IBOutlet NSButton *exportButton;

/**
 *  The .m file checkbox
 */
@property (assign) IBOutlet NSButton *mCheckbox;

/**
 *  The .xib file checkbox
 */
@property (assign) IBOutlet NSButton *xibCheckbox;

/**
 *  The .storyboard file checkbox
 */
@property (assign) IBOutlet NSButton *sbCheckbox;

/**
 *  The .cpp file checkbox
 */
@property (assign) IBOutlet NSButton *cppCheckbox;

/**
 *  The .h file checkbox
 */
@property (assign) IBOutlet NSButton *headerCheckbox;

/**
 *  The .html file checkbox
 */
@property (assign) IBOutlet NSButton *htmlCheckbox;

/**
 *  The .mm file checkbox
 */
@property (assign) IBOutlet NSButton *mmCheckbox;

/**
 *  The .plist file checkbox
 */
@property (assign) IBOutlet NSButton *plistCheckbox;

/**
 *  The .css file checkbox
 */
@property (assign) IBOutlet NSButton *cssCheckbox;

/**
 *  The .swift file checkbox
 */
@property (assign) IBOutlet NSButton *swiftCheckbox;

/**
 *  The enum checkbox
 */
@property (assign) IBOutlet NSButton *enumCheckbox;

// ------ Actions ------
/**
 *  The browse for xcode project action
 *
 *  @param sender The browse button
 */
- (IBAction)browseButtonSelected:(id)sender;

/**
 *  Start the search process
 *
 *  @param sender The search button
 */
- (IBAction)startSearch:(id)sender;

/**
 *  Export the results to a file
 *
 *  @param sender The export button
 */
- (IBAction)exportButtonSelected:(id)sender;

@end
