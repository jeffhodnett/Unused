//
//  RMSkinnedView.m
//
//  Created by Raffael Hannemann on 25.09.12.
//  Copyright (c) 2012 Raffael Hannemann. All rights reserved.
//

#import "RMSkinnedView.h"

@implementation RMSkinnedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.patternOffset = NSMakePoint(0, 0);
		self.cornerRadius = @0;
		self.roundedBottomLeft = NO;
		self.roundedBottomRight = NO;
		self.roundedTopLeft = NO;
		self.roundedTopRight = NO;
		self.fixPatternOrigin = NO;
		self.mouseDownCanMoveWindow = NO;
		self.dontDrawAsPattern = YES;
    }
	return self;
}

- (BOOL) shouldDrawColor {
	return YES;
}

- (void) awakeFromNib {
	if (self.backgroundPatternImageName) {
		self.backgroundPatternImage = [NSImage imageNamed:self.backgroundPatternImageName];
	}
}

- (void) setBackgroundPatternImageName:(NSString *)backgroundPatternImageName {
	_backgroundPatternImageName = backgroundPatternImageName;
	self.backgroundPatternImage = [NSImage imageNamed:self.backgroundPatternImageName];
}

- (void) setColorString:(NSString *)colorString {
	NSArray *comps = [colorString componentsSeparatedByString:@","];
	int r = [(NSString *)comps[0] intValue];
	int g = [(NSString *)comps[1] intValue];
	int b = [(NSString *)comps[2] intValue];
	float a = [(NSString *)comps[3] floatValue];

	self.color = [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

- (void) setBackgroundPatternImage:(NSImage *)backgroundPatternImage {
	_backgroundPatternImage = backgroundPatternImage;
	patternColor = [NSColor colorWithPatternImage:self.backgroundPatternImage];
}

- (void) setOffsetString:(NSString *)offsetString {
	NSArray *comps = [offsetString componentsSeparatedByString:@","];
	int x = [(NSString *)comps[0] intValue];
	int y = [(NSString *)comps[1] intValue];
	self.patternOffset = NSMakePoint(x, y);
}

- (void)drawRect:(NSRect)rect {
	[[NSColor clearColor] set];
    NSRectFillUsingOperation(rect, NSCompositeSourceOver);

	NSPoint point = self.patternOffset;
	if (self.fixPatternOrigin) {
		point.y = self.window.frame.size.height+self.patternOffset.y;
		point.x = self.window.frame.size.width+self.patternOffset.x-self.frame.origin.x;
	}
	[[NSGraphicsContext currentContext] setPatternPhase:point];
	if (!self.backgroundPatternImage && !self.color)
		return;

	if (!self.dontDrawAsPattern) {
		if (patternColor) [patternColor set];
		else [self.color set];

		float roundedRectangleCornerRadius = self.cornerRadius.floatValue;
		NSRect roundedRectangleRect = self.bounds;
		NSRect roundedRectangleInnerRect = NSInsetRect(roundedRectangleRect, roundedRectangleCornerRadius, roundedRectangleCornerRadius);
		NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPath];

		if (self.roundedBottomLeft)
			[roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(roundedRectangleInnerRect), NSMinY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 180 endAngle: 270];
		else
			[roundedRectanglePath moveToPoint: NSMakePoint(NSMinX(roundedRectangleRect), NSMinY(roundedRectangleRect))];

		if (self.roundedBottomRight)
			[roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMaxX(roundedRectangleInnerRect), NSMinY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 270 endAngle: 360];
		else
			[roundedRectanglePath lineToPoint: NSMakePoint(NSMaxX(roundedRectangleRect), NSMinY(roundedRectangleRect))];

		if (self.roundedTopRight)
			[roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMaxX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 0 endAngle: 90];
		else
			[roundedRectanglePath lineToPoint: NSMakePoint(NSMaxX(roundedRectangleRect), NSMaxY(roundedRectangleRect))];

		if (self.roundedTopLeft)
			[roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 90 endAngle: 180];
		else
			[roundedRectanglePath lineToPoint: NSMakePoint(NSMinX(roundedRectangleRect), NSMaxY(roundedRectangleRect))];
		[roundedRectanglePath closePath];
		[roundedRectanglePath fill];

	} else {
		// draw as Image, not as pattern
		float width = self.backgroundPatternImage.size.width;
		float height = self.backgroundPatternImage.size.height;
		NSPoint point = NSMakePoint(ceilf(self.bounds.size.width/2.0-width/2.0), ceilf(self.bounds.size.height/2.0-height/2.0));
		//[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationNone];
		[self.backgroundPatternImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

- (BOOL) mouseDownMovesWindow {
	return self.mouseDownCanMoveWindow;
}

@end
