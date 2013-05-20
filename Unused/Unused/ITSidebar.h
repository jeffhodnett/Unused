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
//  ITSidebar.h
//  ITSidebar
//
//  Created by Ilija Tovilo on 2/22/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ITSidebarItemCell;

@interface ITSidebar : NSView
@property (strong) NSMatrix *matrix;

@property (strong, nonatomic) id target;
@property (nonatomic) SEL action;

// Customisation
@property (nonatomic) NSSize cellSize;
@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) NSScrollerKnobStyle scrollerKnobStyle;
@property (nonatomic) ITSidebarItemCell *selectedItem;
@property (nonatomic) int selectedIndex;
@property (nonatomic) BOOL allowsEmptySelection;

+ (Class)sidebarItemCellClass;

// Add/Remove Cells
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image target:(id)target action:(SEL)action;
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image alternateImage:(NSImage *)alternateImage target:(id)target action:(SEL)action;

- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image;
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image alternateImage:(NSImage *)alternateImage;

- (void)removeRow:(NSInteger)row;

// Select Cells
- (void)deselectAllItems;

@end
