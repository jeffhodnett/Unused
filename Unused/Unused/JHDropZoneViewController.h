//
//  JHDropZoneViewController.h
//  Unused
//
//  Created by Jeff Hodnett on 5/15/13.
//
//

#import <Cocoa/Cocoa.h>
#import "JHViewController.h"
#import "JHDropzoneView.h"

@interface JHDropZoneViewController : JHViewController<JHDropzoneViewDelegate>

@property(assign) IBOutlet JHDropzoneView *dropzoneView;

@end
