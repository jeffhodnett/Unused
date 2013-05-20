//
//  UnusedAppDelegate.h
//  Unused
//
//  Created by Jeff Hodnett on 19/11/2011.
//  Copyright 2011 Seamonster Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JHViewController.h"

@class ITSidebar;

@interface UnusedAppDelegate : NSObject <NSApplicationDelegate, JHViewControllerDelegate> {

@private
    
    // Views data
    NSMutableArray *_viewsList;
    NSMutableDictionary *_viewControllersCache;
    
}

// Outlets
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ITSidebar *sidebar;
@property (assign) IBOutlet NSView *contentView;

@end
