//
//  JHDropzoneView.m
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import "JHDropzoneView.h"
#import <QuartzCore/QuartzCore.h>

@implementation JHDropzoneView

@synthesize delegate=_delegate;

- (void)awakeFromNib
{
    // Register dragging
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
    // Setup state
    viewState = JHDropzoneStateNormal;
    
    // Add image
    NSImage *dropzoneImage = [self imageForState:viewState];
    CGRect rect = CGRectMake(0.5f*(self.bounds.size.width-dropzoneImage.size.width), 0.5f*(self.bounds.size.height-dropzoneImage.size.height), dropzoneImage.size.width, dropzoneImage.size.height);
    _dropzoneImageView = [[NSImageView alloc] initWithFrame:rect];
    [_dropzoneImageView setImage:dropzoneImage];
    [self addSubview:_dropzoneImageView];
}

- (void)dealloc
{
    [_dropzoneImageView release];
    
    [super dealloc];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    // Check the item
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *path in paths) {
            
            NSError *error = nil;
            NSString *utiType = [[NSWorkspace sharedWorkspace]
                                 typeOfFile:path error:&error];
            if (![[NSWorkspace sharedWorkspace] type:utiType conformsToType:(id)kUTTypeFolder]) {
                
                // Update state
                [self setState:JHDropzoneStateEnterBad];
                
                return NSDragOperationNone;
            }
            
        }
    }
    
    // Update state
    [self setState:JHDropzoneStateEnterGood];
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    // Update the exit
    [self setState:JHDropzoneStateExit];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *path in paths) {
            // Error check
            NSError *error = nil;
            NSString *utiType = [[NSWorkspace sharedWorkspace]
                                 typeOfFile:path error:&error];
            if ([[NSWorkspace sharedWorkspace] type:utiType conformsToType:(id)kUTTypeFolder]) {
                
                // Notify the delegate
                if(self.delegate && [self.delegate respondsToSelector:@selector(dropzoneView:didReceiveFolder:)]) {
                    [self.delegate dropzoneView:self didReceiveFolder:path];
                }
            }
            
        }
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    [self setState:JHDropzoneStateNormal];
    
    return YES;
}

- (NSImage *)imageForState:(JHDropzoneState)state
{
    NSImage *dropzoneImage = [NSImage imageNamed:@"dropzone-normal"];
    
    switch (state) {
        case JHDropzoneStateEnterGood:
            dropzoneImage = [NSImage imageNamed:@"dropzone-ok"];
            break;
        case JHDropzoneStateEnterBad:
            dropzoneImage = [NSImage imageNamed:@"dropzone-error"];
            break;
        case JHDropzoneStateNormal:
        default:
            dropzoneImage = [NSImage imageNamed:@"dropzone-normal"];
            break;
    }
    
    return dropzoneImage;
}

-(void)setState:(JHDropzoneState)state
{
    viewState = state;
    
    // Update image
    NSImage *image = [self imageForState:viewState];
    [_dropzoneImageView setImage:image];

    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)frame
{
    [super drawRect:frame];
        
    // Draw a background
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:frame];
    [path setLineWidth:5.0f];

    double lineDash[6];
    lineDash[0] = 40.0;
    lineDash[1] = 12.0;
    lineDash[2] = 8.0;
    lineDash[3] = 12.0;
    lineDash[4] = 8.0;
    lineDash[5] = 12.0;
    [path setLineDash:lineDash count:6 phase:0.0];
    
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    [path setMiterLimit:0.5f];
    [path stroke];
        
    // Extra drawing based on state
    if(viewState == JHDropzoneStateEnterBad) {
        [NSBezierPath setDefaultLineWidth:6.0];
        [[NSColor redColor] set];
        [NSBezierPath strokeRect:frame];
    }
    
    // Update image position
    CGRect imageFrame = _dropzoneImageView.frame;
    imageFrame.origin.x = 0.5f * (self.bounds.size.width-imageFrame.size.width);
    imageFrame.origin.y = 0.5f*(self.bounds.size.height-imageFrame.size.height);
    [_dropzoneImageView setFrame:imageFrame];
}

/*
- (void) setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    
    // A change in size has required the view to be invalidated.
    if ([self inLiveResize])
    {
        NSRect rects[4];
        NSInteger count;
        [self getRectsExposedDuringLiveResize:rects count:&count];
        while (count-- > 0)
        {
            [self setNeedsDisplayInRect:rects[count]];
        }
    }
    else
    {
        [self setNeedsDisplay:YES];
    }
}
*/

@end
