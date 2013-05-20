//
//  JHScanSettingsViewController.m
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import "JHScanSettingsViewController.h"
#import "JHScanFilesSetting.h"

@interface JHScanSettingsViewController ()

@end

@implementation JHScanSettingsViewController

@synthesize mCheckbox=_mCheckbox;
@synthesize xibCheckbox=_xibCheckbox;
@synthesize cppCheckbox=_cppCheckbox;
@synthesize mmCheckbox=_mmCheckbox;
@synthesize htmlCheckbox =_htmlCheckbox;
@synthesize plistCheckbox =_plistCheckbox;
@synthesize cssCheckbox =_cssCheckbox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - Actions
- (IBAction)continueSelected:(id)sender
{
    // Notify delegate
    if(self.delegate && [self.delegate respondsToSelector:@selector(viewController:didChooseSetting:)]) {
        // Pass setting to delegate
        JHScanFilesSetting *setting = [[JHScanFilesSetting alloc] init];
        setting.mCheckboxSelected = [_mCheckbox state];
        setting.xibCheckbox = [_xibCheckbox state];
        setting.cppCheckbox = [_cppCheckbox state];
        setting.mmCheckbox = [_mmCheckbox state];
        setting.htmlCheckbox = [_htmlCheckbox state];
        setting.plistCheckbox = [_plistCheckbox state];
        setting.cssCheckbox = [_cssCheckbox state];
        [self.delegate viewController:self didChooseSetting:setting];
        [setting release];
    }
}

@end
