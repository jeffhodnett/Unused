// DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
// Version 2, December 2004
//
// Copyright (C) 2013 Ilija Tovilo <support@ilijatovilo.ch>
//
// Everyone is permitted to copy and distribute verbatim or modified
// copies of this license document, and changing it is allowed as long
// as the name is changed.
//
// DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
// TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
//
// 0. You just DO WHAT THE FUCK YOU WANT TO.

//
//  ITSidebarCell.m
//  ITSidebar
//
//  Created by Ilija Tovilo on 2/22/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#import "ITSidebarItemCell.h"

#define kSelectionCornerRadius 5.0
#define kSelectionWidth 2.0

#define kSelectionColor [NSColor colorWithCalibratedRed:0.12f green:0.49f blue:0.93f alpha:1.f]
#define kSelectionHighlightColor [NSColor colorWithCalibratedRed:0.12f green:0.49f blue:0.93f alpha:0.7f]

@implementation ITSidebarItemCell

- (void)drawImageWithFrame:(NSRect)frame inView:(NSView *)controlView {
    NSImage *image;
    if ((self.isHighlighted || [self state] == NSOnState) && self.alternateImage) {
        image = self.alternateImage;
    } else {
        image = self.image;
    }
    [self drawImage:image withFrame:frame inView:controlView];
}
- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowOffset:NSMakeSize(0, -1)];
        [shadow setShadowColor:[NSColor blackColor]];
        [shadow setShadowBlurRadius:3.0];
        [shadow set];
        
        NSRect imgRect = NSInsetRect(frame, ( NSWidth(frame) -[image size].width)/2.0, ( NSHeight(frame) -[image size].height)/2.0);
        [image drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (NSShadow *)shadow {
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowOffset:NSMakeSize(0, -1)];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowBlurRadius:3.0];
    
    return shadow;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [NSGraphicsContext saveGraphicsState];
    {
        [[self shadow] set];
        [[NSColor whiteColor] set];
        
        [super drawTitle:self.attributedTitle withFrame:cellFrame inView:controlView];
        [self drawImageWithFrame:cellFrame inView:controlView];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawBackgroundWithFrame:(NSRect)frame inView:(NSView *)view {
    // We do nothing for this example here..
}

- (void)drawSelectionWithFrame:(NSRect)frame inView:(NSView *)view {
    if ([self state] == NSOnState) {
        [kSelectionColor set];
    } else {
        [kSelectionHighlightColor set];
    }
    
    NSRect strokeRect = NSInsetRect(frame, 10, 10);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:strokeRect xRadius:kSelectionCornerRadius yRadius:kSelectionCornerRadius];
    [path setLineWidth:kSelectionWidth];
    [path stroke];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view {
	[NSGraphicsContext saveGraphicsState];
    {
        [self drawBackgroundWithFrame:frame inView:view];
        [self drawInteriorWithFrame:frame inView:view];
    
        if([self state] == NSOnState || [self isHighlighted])
        {
            [self drawSelectionWithFrame:frame inView:view];
        }
    }
    [NSGraphicsContext restoreGraphicsState];
}


@end
