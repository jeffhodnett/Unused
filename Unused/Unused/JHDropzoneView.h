//
//  JHDropzoneView.h
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import <Cocoa/Cocoa.h>
#import "JHSpeechBubbleView.h"

@class  JHDropzoneView;

@protocol JHDropzoneViewDelegate <NSObject>

@optional
-(void)dropzoneView:(JHDropzoneView *)view didReceiveFolder:(NSString *)folderPath;

@end

typedef enum {
    JHDropzoneStateNormal = 0,
    JHDropzoneStateEnterGood = 1,
    JHDropzoneStateEnterBad = 2,
    JHDropzoneStateExit = 3
} JHDropzoneState;

@interface JHDropzoneView : NSView
{
    JHDropzoneState _viewState;
    NSImageView *_dropzoneImageView;
    
    JHSpeechBubbleView *_speechBubbleView;
}

@property (assign) id<JHDropzoneViewDelegate> delegate;

@end
