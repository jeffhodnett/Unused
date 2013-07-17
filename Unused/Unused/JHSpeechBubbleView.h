//
//  JHSpeechBubbleView.h
//  SpeechBubble
//
//  Created by Jeff Hodnett on 5/31/13.
//
//


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

typedef enum {
  JHSpeechBubbleTypeNormal = 0,
  JHSpeechBubbleTypeDashed = 1
} JHSpeechBubbleType;

typedef enum {
    JHSpeechBubblePointerPositionBottomLeft = 0,
    JHSpeechBubblePointerPositionBottomCenter = 1,
    JHSpeechBubblePointerPositionBottomRight = 2,
    JHSpeechBubblePointerPositionTopLeft = 3,
} JHSpeechBubblePointerPosition;

@class JHSpeechBubbleModel;


#if TARGET_OS_IPHONE
// iOS
@interface JHSpeechBubbleView : UIView
{
    JHSpeechBubbleType _bubbleType;
    JHSpeechBubblePointerPosition _pointerPosition;
}

@property(nonatomic) BOOL showsDropShadow;
@property(nonatomic, retain) UIColor *fillColor;
@property(nonatomic, retain) UIColor *strokeColor;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) NSString *textFontName;

+(id)bubbleViewWithFrame:(CGRect)frameRec;

-(void)setPointerPosition:(JHSpeechBubblePointerPosition)position;
-(void)setBubbleType:(JHSpeechBubbleType)type;
-(void)setBubbleText:(NSString *)text;
-(void)setBubbleFontName:(NSString *)fontName;
-(void)setBubbleTextColor:(UIColor *)color;
-(void)setBubbleFillColor:(UIColor *)fillColor;
-(void)setBubbleStrokeColor:(UIColor *)strokeColor;

#else
// Mac
@interface JHSpeechBubbleView : NSView
{
    JHSpeechBubbleType _bubbleType;
    JHSpeechBubblePointerPosition _pointerPosition;
}

@property(nonatomic) BOOL showsDropShadow;
@property(nonatomic, retain) NSColor *fillColor;
@property(nonatomic, retain) NSColor *strokeColor;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSColor *textColor;
@property(nonatomic, retain) NSString *textFontName;

+(id)bubbleViewWithFrame:(NSRect)frameRec;

-(void)setPointerPosition:(JHSpeechBubblePointerPosition)position;
-(void)setBubbleType:(JHSpeechBubbleType)type;
-(void)setBubbleText:(NSString *)text;
-(void)setBubbleFontName:(NSString *)fontName;
-(void)setBubbleTextColor:(NSColor *)color;
-(void)setBubbleFillColor:(NSColor *)fillColor;
-(void)setBubbleStrokeColor:(NSColor *)strokeColor;
#endif

@end