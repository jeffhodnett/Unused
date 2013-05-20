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
//  ITSidebar.m
//  ITSidebar
//
//  Created by Ilija Tovilo on 2/22/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#import "ITSidebar.h"
#import "ITSidebarItemCell.h"
#import "ITLeakWarningHelper.h"

#define kDefaultBackgroundColor [NSColor colorWithDeviceWhite:0.16 alpha:1.0]
#define kDefaultScrollerKnobStyle NSScrollerKnobStyleLight
#define kDefaultAllowsEmptySelection YES

@implementation ITSidebar
@synthesize action = _action;
@synthesize target = _target;

#pragma mark Initialise
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    
    return self;
}
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialise];
    }
    return self;
}
- (void)awakeFromNib {
    [self resizeMatrix];
    [self initialiseScrollView];
}
- (void)initialise {
    [self addMatrix];
    
    [[self enclosingScrollView] setDrawsBackground:YES];
    
    NSClipView *clipView = [[self enclosingScrollView] contentView];
    [clipView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resizeMatrix)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}
- (void)initialiseScrollView {
    [[self enclosingScrollView] setDrawsBackground:YES];
    
    // Style scroll view
    [[self enclosingScrollView] setBorderType:NSNoBorder];
    [self setBackgroundColor:kDefaultBackgroundColor];
    [self setScrollerKnobStyle:kDefaultScrollerKnobStyle];
}
- (void)addMatrix {
    self.matrix = [[NSMatrix alloc] initWithFrame:[self frame]
                                             mode:NSRadioModeMatrix
                                        cellClass:[[self.class sidebarItemCellClass] class]
                                     numberOfRows:0
                                  numberOfColumns:1];
    
    [self.matrix setAllowsEmptySelection:kDefaultAllowsEmptySelection];
    [self.matrix setCellSize:[[self class] defaultCellSize]];
    
    [self resizeMatrix];
    [self addSubview:self.matrix];
}
#pragma mark Scroll View
- (NSColor *)backgroundColor {
    return [[self enclosingScrollView] backgroundColor];
}
- (void)setBackgroundColor:(NSColor *)backgroundColor {
    [[self enclosingScrollView] setBackgroundColor:backgroundColor];
}
- (NSScrollerKnobStyle)scrollerKnobStyle {
    return [[self enclosingScrollView] scrollerKnobStyle];
}
- (void)setScrollerKnobStyle:(NSScrollerKnobStyle)knobStyle {
    [[self enclosingScrollView] setScrollerKnobStyle:knobStyle];
}

#pragma mark Key Handling
- (BOOL)acceptsFirstResponder {
    return YES;
}
- (void)keyDown:(NSEvent *)theEvent {
    // NSLog(@"%d", theEvent.keyCode);
    switch (theEvent.keyCode) {
        case 126: // Up
        {
            [self selectPreviousItem];
        }
            break;
        case 125: // Down
        {
            [self selectNextItem];
        }
            break;
        case 53: // Down
        {
            [self deselectAllItems];
        }
            break;
        default:
        {
            [super keyDown:theEvent];
        }
            break;
    }
}
- (void)deselectAllItems {
    [self.matrix deselectSelectedCell];
    
    // For some reason the matrix does not call the action like this.. :/
    // So we do it manually
    [self matrixCallback:self];
    
}
- (void)selectNextItem {
    [self selectNeighbourItemWithValue:1];
}

- (void)selectPreviousItem {
    [self selectNeighbourItemWithValue:-1];
}

- (void)selectNeighbourItemWithValue:(int)value {
    self.selectedIndex = self.selectedIndex + value;
}

#pragma mark Cells
- (ITSidebarItemCell *)selectedItem {
    return self.matrix.selectedCell;
}
- (void)setSelectedItem:(ITSidebarItemCell *)selectedItem {
    self.selectedIndex = [[self.matrix cells] indexOfObject:selectedItem];
}
- (int)selectedIndex {
    ITSidebarItemCell *cell = [self selectedItem];
    return (int)[self.matrix.cells indexOfObject:cell];
}
- (void)setSelectedIndex:(int)index {
    if (index >= 0 && index < self.matrix.cells.count) {
        [self.matrix selectCell:[self.matrix.cells objectAtIndex:index]];
        
        // Again, no action
        [self matrixCallback:self];
    }
}
+ (NSSize)defaultCellSize {
    return NSMakeSize(62, 62);
}
- (NSSize)cellSize {
    return [self.matrix cellSize];
}
- (void)setCellSize:(NSSize)cellSize {
    [self.matrix setCellSize:cellSize];
}
- (BOOL)allowsEmptySelection {
    return self.matrix.allowsEmptySelection;
}
- (void)setAllowsEmptySelection:(BOOL)allowsEmptySelection {
    [self.matrix setAllowsEmptySelection:allowsEmptySelection];
    
    // If empty selection is not allowed, we select the first item
    if (!allowsEmptySelection && [self selectedIndex] == -1) {
        self.selectedIndex = 0;
    }
}

+ (Class)sidebarItemCellClass {
    return [ITSidebarItemCell class];
}
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image target:(id)target action:(SEL)action {
    ITSidebarItemCell *cell = [[[self.class sidebarItemCellClass] alloc] initImageCell:image];
    [cell setTarget:target];
    [cell setAction:action];
    [self addCell:cell];
    
    return cell;
}
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image alternateImage:(NSImage *)alternateImage target:(id)target action:(SEL)action {
    ITSidebarItemCell *cell = [self addItemWithImage:image target:target action:action];
    [cell setAlternateImage:alternateImage];
    
    return cell;
}
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image {
    ITSidebarItemCell *cell = [[[self.class sidebarItemCellClass] alloc] initImageCell:image];
    [self addCell:cell];
    
    return cell;
}
- (ITSidebarItemCell *)addItemWithImage:(NSImage *)image alternateImage:(NSImage *)alternateImage {
    ITSidebarItemCell *cell = [self addItemWithImage:image];
    [cell setAlternateImage:alternateImage];
    
    return cell;
}
- (void)addCell:(ITSidebarItemCell *)cell {
    [self.matrix addRowWithCells:@[ cell ]];
    [self resizeMatrix];
}
- (void)removeRow:(NSInteger)row {
    [self.matrix removeRow:row];
    [self resizeMatrix];
}

#pragma mark Resizing
- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self resizeMatrix];
}
- (void)resizeMatrix {
    [self.matrix sizeToCells];
    
    NSRect newSize = self.matrix.frame;
    if (NSHeight([[self enclosingScrollView].contentView frame]) > NSHeight(newSize)) {
        newSize.size.height = NSHeight([[self enclosingScrollView].contentView frame]);
    }

    [self.matrix setFrameSize:newSize.size];
    [self setFrameSize:newSize.size];
}

#pragma mark ITSidebar Target Action
- (IBAction)matrixCallback:(id)sender {
    if ([self.target respondsToSelector:self.action]) {
        SuppressPerformSelectorLeakWarning(
            [self.target performSelector:self.action withObject:self];
        );
    } else {
        // Very ugly hack, because again the action is not invoked by the NSButtonCell
        // NSButtonCell's performClick: causes some unexpected behaviour.
        // If anyone finds another way of doing this, let me know over Github ;)
        if ([self.selectedItem.target respondsToSelector:self.selectedItem.action]) {
            SuppressPerformSelectorLeakWarning(
                [self.selectedItem.target performSelector:self.selectedItem.action withObject:self.selectedItem];
            );
        }
    }
}
- (void)setTarget:(id)target {
    [self.matrix setTarget:self];
    _target = target;
}
- (void)setAction:(SEL)action {
    [self.matrix setAction:@selector(matrixCallback:)];
    _action = action;
}

@end