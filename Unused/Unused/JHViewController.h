//
//  JHViewController.h
//  Unused
//
//  Created by Jeff Hodnett on 5/15/13.
//
//

#import <Cocoa/Cocoa.h>

@class JHViewController;
@class JHScanSetting;

@protocol JHViewControllerDelegate <NSObject>

@optional
-(void)viewController:(JHViewController *)vc didChooseSetting:(JHScanSetting *)setting;

@end

@interface JHViewController : NSViewController

@property(nonatomic, assign) id<JHViewControllerDelegate> delegate;
@property(nonatomic) int viewIndex;

@end
