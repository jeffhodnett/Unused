//
//  RMSkinnedView.h
//
//  Created by Raffael Hannemann on 25.09.12.
//  Copyright (c) 2012 Raffael Hannemann. All rights reserved.
//

// Under BSD License

/**
 * This subclass of NSView uses a NSImage as pattern or a NSColor to fill its background.
 *
 * In Interface Builder you can specify the property 'backgroundPatternImageName' and others
 * to specify the image name of the view's background image without subclassing or
 * referencing-and-setting it.
 *
 * To highlight which properties can be set in the Interface Builder, we've added the IBOutlet keyword to those properties (ignore warnings).
 */
#import <Cocoa/Cocoa.h>

@interface RMSkinnedView : NSView {
	NSColor *patternColor;
}

/** The image filename in the resources to be used as background pattern.
 */
@property (retain,nonatomic) NSImage *backgroundPatternImage;

/** The image to be used as background pattern.
 */
@property (retain,nonatomic) IBOutlet NSString *backgroundPatternImageName;

/** The string for the color, which will be used if image not loaded */
@property (retain,nonatomic) IBOutlet NSString *colorString;

/** The color, which will be used if image not loaded */
@property (retain,nonatomic) NSColor *color;

/** The string for the pattern offset. */
@property (retain,nonatomic) IBOutlet NSString *offsetString;

/** The resulting pattern offset NSPoint. */
@property (assign,nonatomic) NSPoint patternOffset;

/** The corner radius, will be used for every corner. Default: 0. */
@property (retain) IBOutlet NSNumber *cornerRadius;

/** The flags for each of the four corners. Default: NO. */
@property (assign) IBOutlet BOOL roundedTopLeft;
@property (assign) IBOutlet BOOL roundedTopRight;
@property (assign) IBOutlet BOOL roundedBottomLeft;
@property (assign) IBOutlet BOOL roundedBottomRight;

/** Set to YES if background image moves while resizing the window. Default: NO.
 */
@property (assign) IBOutlet BOOL fixPatternOrigin;

/** Set to YES if you want to user to move the parent window while dragging the view. Default: NO.
 */
@property (assign) IBOutlet BOOL mouseDownCanMoveWindow;

/** Set to NO if the image shall be painted as pattern, instead of only once, centered in the view. Default: NO.
 */
@property (assign) IBOutlet BOOL dontDrawAsPattern;

@end
