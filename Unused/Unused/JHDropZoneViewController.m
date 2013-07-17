//
//  JHDropZoneViewController.m
//  Unused
//
//  Created by Jeff Hodnett on 5/15/13.
//
//

#import "JHDropZoneViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JHSearchFolderSetting.h"

@interface JHDropZoneViewController ()

@end

@implementation JHDropZoneViewController

@synthesize dropzoneView=_dropzoneView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

-(void) awakeFromNib
{
    // Become dropzone delegate
    self.dropzoneView.delegate = self;
    
    
    // Add info label
//    NSTextField *infoLabel = [[NSTextField alloc] initWithFrame:self.view.bounds];
//    [infoLabel setTextColor:[NSColor blueColor]];
//    [infoLabel setEditable:NO];
//    [infoLabel setSelectable:NO];
//    [infoLabel setBackgroundColor:[NSColor clearColor]];
//    [infoLabel setBezeled:NO];
//    [infoLabel setStringValue:@"Drop project folders here"];
//    [self.view addSubview:infoLabel];
//    [infoLabel release];
    
}

#pragma mark - JHDropzoneViewDelegate Methods
-(void)dropzoneView:(JHDropzoneView *)view didReceiveFolder:(NSString *)folderPath
{
    // Notify delegate
    if(self.delegate && [self.delegate respondsToSelector:@selector(viewController:didChooseSetting:)]) {
        // Pass setting to delegate
        JHSearchFolderSetting *setting = [JHSearchFolderSetting setting];
        setting.searchDirectoryPath = folderPath;
        [self.delegate viewController:self didChooseSetting:setting];
    }
}

@end
