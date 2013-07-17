//
//  UnusedAppDelegate.m
//  Unused
//
//  Created by Jeff Hodnett on 19/11/2011.
//  Copyright 2011 Seamonster Ltd. All rights reserved.
//

#import "UnusedAppDelegate.h"
#import "JHViewController.h"
#import "ITSidebar.h"
#import "JHViewData.h"
#import "JHScanSetting.h"
#import "JHUnusedScanManager.h"

@implementation UnusedAppDelegate

@synthesize window=_window;
@synthesize sidebar=_sidebar;
@synthesize contentView=_contentView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Setup views array
    _viewsList = [[NSMutableArray alloc] init];
    
    // Load views plist
    NSArray *plistData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Views" ofType:@"plist"]];
    for (NSDictionary *data in plistData) {
        JHViewData *viewData = [[JHViewData alloc] init];
        viewData.sidebarIcon = [data objectForKey:@"icon"];
        viewData.sidebarIconPushed = [data objectForKey:@"iconPushed"];
        viewData.viewControllerName = [data objectForKey:@"viewController"];
        [_viewsList addObject:viewData];
        [viewData release];
    }
        
    // Setup sidebar
    SEL sidebarClickSelector = @selector(sidebarItemSelected:);
    for (JHViewData *viewData in _viewsList) {
        NSImage *icon = [NSImage imageNamed:viewData.sidebarIcon];
        NSImage *iconPushed = [NSImage imageNamed:viewData.sidebarIconPushed];
        [self.sidebar addItemWithImage:icon alternateImage:iconPushed target:self action:sidebarClickSelector];
    }

    // Because this mehthod does not support empty selection, we obviously disable it.
    // Note to set the allowsEmptySelection AFTER adding the items, because else it won't be able to select the first item
    self.sidebar.allowsEmptySelection = NO;

    // Setup cache
    _viewControllersCache = [[NSMutableDictionary alloc] init];
    
    // Set current view
    [self setCurrentViewIndex:0];    
}

-(void)dealloc
{
    [_viewsList release];
    [_viewControllersCache release];
    
    [super dealloc];
}


- (IBAction)sidebarChanged:(ITSidebar *)sender
{
#warning handle changes
}

#pragma JHViewControllerDelegate Method
-(void)viewController:(JHViewController *)vc didChooseSetting:(JHScanSetting *)setting
{
    // Get view index data
    int viewIndex = [vc viewIndex];
    int nextIndex = viewIndex + 1;
    if(nextIndex <= [_viewsList count]) {
        [self.sidebar setSelectedIndex:nextIndex];
    }
    
    // Remember the setting
    [[JHUnusedScanManager sharedManager] addSetting:setting atIndex:viewIndex];
}

-(void)setCurrentViewIndex:(int)index
{
#warning check bounds
    
    // Clear previous view
    [self.contentView setSubviews:[NSArray array]];
    
    // Get data
    JHViewData *viewData = [_viewsList objectAtIndex:index];
    NSString *className = viewData.viewControllerName;
    
    // Check cache
    id vc = [_viewControllersCache objectForKey:className];
    if (vc == nil) {
        id Class = NSClassFromString(className);
        if(Class != nil) {
            JHViewController *viewController = [[Class alloc] initWithNibName:className bundle:nil];
            [[viewController view] setFrame:[self.contentView bounds]];
            viewController.delegate = self;
            viewController.viewIndex = index;
            [_viewControllersCache setValue:viewController forKey:className];
            [viewController release];
            
            // Add to current view
            [self.contentView addSubview:[viewController view]];
        }
        else {
#warning implement
            @throw [NSError errorWithDomain:@"" code:1 userInfo:nil];
        }
    }
    else {
        
        // Add to current view
        [self.contentView addSubview:[vc view]];
    }

}

#pragma mark - Sidebar actions
-(void)sidebarItemSelected:(id)sender
{
    // Show view based on selection
    int index = self.sidebar.selectedIndex;
    [self setCurrentViewIndex:index];
}

@end
