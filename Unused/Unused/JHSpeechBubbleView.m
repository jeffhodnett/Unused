//
//  JHSpeechBubbleView.m
//  SpeechBubble
//
//  Created by Jeff Hodnett on 5/31/13.
//
//

#import "JHSpeechBubbleView.h"
#import <QuartzCore/QuartzCore.h>

@implementation JHSpeechBubbleView

@synthesize showsDropShadow=_showsDropShadow;
@synthesize fillColor=_fillColor;
@synthesize strokeColor=_strokeColor;
@synthesize lineWidth=_lineWidth;
@synthesize textColor=_textColor;
@synthesize textFontName=_textFontName;

+(id)bubbleViewWithFrame:(CGRect)frameRect
{
    JHSpeechBubbleView *view = [[[JHSpeechBubbleView alloc] initWithFrame:frameRect] autorelease];
    
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setupDefaults];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self setupDefaults];
    }
    return self;
}

-(void)setupDefaults
{
    _bubbleType = JHSpeechBubbleTypeNormal;
    _pointerPosition = JHSpeechBubblePointerPositionBottomLeft;
//    _pointerPosition = JHSpeechBubblePointerPositionTopLeft;
    
    self.showsDropShadow = YES;
    self.lineWidth = 2.0f;
    self.text = @"Blamm!!";
    
#if TARGET_OS_IPHONE
    self.textFontName = @"Marker Felt";
    self.fillColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    self.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    self.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
#else
    self.textFontName = @"Comic Sans MS";
    self.fillColor = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    self.strokeColor = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    self.textColor = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
#endif

}

-(void)dealloc
{
    [_fillColor release];
    [_strokeColor release];
    [_text release];
    [_textColor release];
    [_textFontName release];
    
    [super dealloc];
}

#pragma mark - View manipulations

#if TARGET_OS_IPHONE
-(void)setPointerPosition:(JHSpeechBubblePointerPosition)position
{
    _pointerPosition = position;
    [self setNeedsDisplay];
}

-(void)setBubbleType:(JHSpeechBubbleType)type
{
    _bubbleType = type;
    [self setNeedsDisplay];
}

-(void)setBubbleText:(NSString *)text
{
    self.text = text;
    [self setNeedsDisplay];
}

-(void)setBubbleTextColor:(UIColor *)color
{
    self.textColor = color;
    [self setNeedsDisplay];
}

-(void)setBubbleFillColor:(UIColor *)fillColor
{
    self.fillColor = fillColor;
    [self setNeedsDisplay];
}

-(void)setBubbleStrokeColor:(UIColor *)strokeColor
{
    self.strokeColor = strokeColor;
    [self setNeedsDisplay];
}

-(void)setBubbleFontName:(NSString *)fontName
{
    self.textFontName = fontName;
    [self setNeedsDisplay];
}

#else 
-(void)setPointerPosition:(JHSpeechBubblePointerPosition)position
{
    _pointerPosition = position;
    [self setNeedsDisplay:YES];
}

-(void)setBubbleType:(JHSpeechBubbleType)type
{
    _bubbleType = type;
    [self setNeedsDisplay:YES];
}

-(void)setBubbleText:(NSString *)text
{
    self.text = text;
    [self setNeedsDisplay:YES];
}

-(void)setBubbleTextColor:(NSColor *)color
{
    self.textColor = color;
    [self setNeedsDisplay:YES];
}

-(void)setBubbleFillColor:(NSColor *)fillColor
{
    self.fillColor = fillColor;
    [self setNeedsDisplay:YES];
}

-(void)setBubbleStrokeColor:(NSColor *)strokeColor
{
    self.strokeColor = strokeColor;
    [self setNeedsDisplay:YES];
}

-(void)setBubbleFontName:(NSString *)fontName
{
    self.textFontName = fontName;
    [self setNeedsDisplay:YES];
}
#endif

#pragma mark - Drawing
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    #if TARGET_OS_IPHONE
    
    // Fill background
    [[UIColor lightGrayColor] setFill];
    UIRectFill(rect);
    
    // Get context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    #else
    // Fill background
//    [[NSColor lightGrayColor] setFill];
//    NSRectFill(rect);
    
    // Get context
    CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    #endif
    
    // Check type
    if(_bubbleType == JHSpeechBubbleTypeNormal) {
    }
    else if(_bubbleType == JHSpeechBubbleTypeDashed) {
        // Dashes
        CGFloat dash[] = {40.0, 10.0};
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineDash(ctx, 0.0, dash, 2);
    }

    // Setup some calculatations
    float xPadding = 5.0f;
    float yPadding = 5.0f;
    float bubbleWidth = (self.bounds.size.width * 1.0f)-(xPadding*2.0f);
    float bubbleHeight = (self.bounds.size.height * 0.80f);
    CGRect bubbleRect = CGRectMake(xPadding, (self.bounds.size.height-bubbleHeight)-yPadding, bubbleWidth, bubbleHeight);

    if(_pointerPosition == JHSpeechBubblePointerPositionTopLeft) {
        bubbleRect = CGRectMake(xPadding, yPadding, bubbleWidth, bubbleHeight);
    }
    
#if TARGET_OS_IPHONE
    
    // TODO: Transform the view to be an ios co-ord system
    
    // Setup drawing values
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
    CGContextSetLineWidth(ctx, _lineWidth);

#else
    // Setup drawing values
    CGContextSetFillColorWithColor(ctx, [self CGColor:self.fillColor]);
    CGContextSetStrokeColorWithColor(ctx, [self CGColor:self.strokeColor]);
    CGContextSetLineWidth(ctx, _lineWidth);
            
    // Setup shadow
    if(self.showsDropShadow) {
        NSColor *shadowColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -2), 1.0, [self CGColor:shadowColor]);
    }
#endif
    
    // Draw ellipse
    CGContextFillEllipseInRect(ctx, bubbleRect);
    CGContextStrokeEllipseInRect(ctx, bubbleRect);
    
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    CGPoint p3 = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    // Draw arrow
    switch (_pointerPosition) {
        case JHSpeechBubblePointerPositionBottomCenter:
            p1 = [self pointOnEllipseRect:bubbleRect withAngle:260.0f];
            p2 = [self pointOnEllipseRect:bubbleRect withAngle:280.0f];
            p3 = CGPointMake((p1.x+p2.x)/2.0f, p1.y+30.0f);
            endPoint = CGPointMake((p1.x+p2.x)/2.0f, 10.0f);
            break;
        case JHSpeechBubblePointerPositionBottomLeft:
            p1 = [self pointOnEllipseRect:bubbleRect withAngle:210.0f];
            p2 = [self pointOnEllipseRect:bubbleRect withAngle:235.0f];
            p3 = CGPointMake(p2.x, p1.y);
            endPoint = CGPointMake(bubbleRect.origin.x, bubbleRect.origin.y);
            break;
        case JHSpeechBubblePointerPositionBottomRight:
            p1 = [self pointOnEllipseRect:bubbleRect withAngle:310.0f];
            p2 = [self pointOnEllipseRect:bubbleRect withAngle:335.0f];
            p3 = CGPointMake(p1.x, p2.y);
            endPoint = CGPointMake(bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y);
            break;
        case JHSpeechBubblePointerPositionTopLeft:
            p1 = [self pointOnEllipseRect:bubbleRect withAngle:30.0f];
            p2 = [self pointOnEllipseRect:bubbleRect withAngle:55.0f];
            p3 = CGPointMake(p2.x, p1.y);
            endPoint = CGPointMake(bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height);
            break;
        default:
            break;
    }
    
    // Now draw the bubble arrow
    // Fill
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, endPoint.x, endPoint.y);
    CGContextAddLineToPoint(ctx, p1.x, p1.y);
    CGContextAddQuadCurveToPoint(ctx, p3.x, p3.y, p2.x, p2.y);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // Stroke
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, endPoint.x, endPoint.y);
    CGContextAddLineToPoint(ctx, p1.x, p1.y);
    CGContextMoveToPoint(ctx, endPoint.x, endPoint.y);
    CGContextAddLineToPoint(ctx, p2.x, p2.y);
    CGContextStrokePath(ctx);
    
    // Draw text
    BOOL textFits = NO;
    float fontSize = 150.0f;
    float fontSizePadding = 60.0f;
    while(!textFits) {
        #if TARGET_OS_IPHONE
        // Create attributes
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:self.textFontName size:fontSize], NSFontAttributeName,
                                    self.textColor, NSForegroundColorAttributeName,
                                    nil];
        #else 
        // Create attributes
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont fontWithName:self.textFontName size:fontSize], NSFontAttributeName,
                                    self.textColor, NSForegroundColorAttributeName,
                                    [NSColor clearColor], NSBackgroundColorAttributeName,
                                    nil];
        #endif
        NSAttributedString *currentText = [[NSAttributedString alloc] initWithString:self.text attributes: attributes];
        
        CGSize attrSize = [currentText size];
        if(attrSize.width > bubbleRect.size.width-fontSizePadding){
            fontSize-=2.0f;
        }
        else {
            float textX = bubbleRect.origin.x + bubbleRect.size.width/2 - attrSize.width/2;
            float textY = bubbleRect.origin.y + bubbleRect.size.height/2 - attrSize.height/2;
            [currentText drawAtPoint:CGPointMake(textX, textY)];
            
            textFits = YES;
        }

        // Stop infinite looping
        if(fontSize <= 1.0f) {
            textFits = YES;
        }
    }
}

-(CGPoint)pointOnEllipseRect:(CGRect)ellipseRect withAngle:(CGFloat)angle
{
    // Get the center of the ellipse
    CGPoint center = CGPointMake(ellipseRect.origin.x+ellipseRect.size.width/2, ellipseRect.origin.y+ellipseRect.size.height/2);

    // Convert angle to radians
    float angleRadians = DegreesToRadians(angle);
    
    // Calculate a, b
    float a = ellipseRect.size.width/2;
    float b = ellipseRect.size.height/2;
    
    // x = a cos t
    // y = b sin t
    float x = center.x + a * cosf(angleRadians);
    float y = center.y + b * sinf(angleRadians);
    
    // Create point
    CGPoint point = CGPointMake(x, y);
    
    return point;
}

#pragma mark - Helpers
CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

#if TARGET_OS_IPHONE

#else
- (CGColorRef)CGColor:(NSColor *)color
{
    const NSInteger numberOfComponents = [color numberOfComponents];
    CGFloat components[numberOfComponents];
    CGColorSpaceRef colorSpace = [[color colorSpace] CGColorSpace];
    
    [color getComponents:(CGFloat *)&components];
    
    return (CGColorRef)[(id)CGColorCreate(colorSpace, components) autorelease];
}
#endif

@end
