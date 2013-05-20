//
//  JHViewData.m
//  Unused
//
//  Created by Jeff Hodnett on 5/17/13.
//
//

#import "JHViewData.h"

@implementation JHViewData

@synthesize sidebarIcon=_sidebarIcon;
@synthesize sidebarIconPushed=_sidebarIconPushed;
@synthesize viewControllerName=_viewControllerName;

-(void)dealloc
{
    [_sidebarIcon release];
    [_sidebarIconPushed release];
    [_viewControllerName release];
    
    [super dealloc];
}

@end
