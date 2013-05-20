//
//  JHScanSettingsViewController.h
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import <Cocoa/Cocoa.h>
#import "JHViewController.h"

@interface JHScanSettingsViewController : JHViewController

@property (assign) IBOutlet NSButton *mCheckbox;
@property (assign) IBOutlet NSButton *xibCheckbox;
@property (assign) IBOutlet NSButton *cppCheckbox;
@property (assign) IBOutlet NSButton *htmlCheckbox;
@property (assign) IBOutlet NSButton *mmCheckbox;
@property (assign) IBOutlet NSButton *plistCheckbox;
@property (assign) IBOutlet NSButton *cssCheckbox;

// Actions
- (IBAction)continueSelected:(id)sender;

@end
