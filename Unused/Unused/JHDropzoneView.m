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
    _viewState = JHDropzoneStateNormal;
    
    // Add speech bubble
    float speechBubbleW = 200.0f;
    float speechBubbleH = 200.0f;
    CGRect speechBubbleRect = CGRectMake(0.5f*(self.bounds.size.width-speechBubbleW), 0.5f*(self.bounds.size.height-speechBubbleH), speechBubbleW, speechBubbleH);
    _speechBubbleView = [[JHSpeechBubbleView alloc] initWithFrame:speechBubbleRect];
    [_speechBubbleView setBubbleText:[self textStatusForState:_viewState]];
    [_speechBubbleView setPointerPosition:JHSpeechBubblePointerPositionBottomCenter];
    [self addSubview:_speechBubbleView];
    
    // Add image
    NSImage *dropzoneImage = [self imageForState:_viewState];
    CGRect rect = CGRectMake(0.5f*(self.bounds.size.width-dropzoneImage.size.width), 0.5f*(self.bounds.size.height-dropzoneImage.size.height), dropzoneImage.size.width, dropzoneImage.size.height);
    _dropzoneImageView = [[NSImageView alloc] initWithFrame:rect];
    [_dropzoneImageView setImage:dropzoneImage];
    [self addSubview:_dropzoneImageView];
}

- (void)dealloc
{
    [_dropzoneImageView release];
    [_speechBubbleView release];
    
    [super dealloc];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    // Check the item
    if(![self isValidDraggableFolder:sender]) {
        // Update state
        [self setState:JHDropzoneStateEnterBad];
        
        return NSDragOperationNone;
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
    // Validate the dragged item
    NSString *path = nil;
    if([self isValidDraggableFolder:sender path:&path]) {
        NSLog(@"path is %@", path);
        
        // Notify the delegate
        if(self.delegate && [self.delegate respondsToSelector:@selector(dropzoneView:didReceiveFolder:)]) {
            [self.delegate dropzoneView:self didReceiveFolder:path];
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

- (BOOL)isValidDraggableFolder:(id <NSDraggingInfo>)sender path:(NSString **)folderPath
{
    // Check drag pasteboard
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        
        // Get paths
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        
        // We are only expecting one item
        if([paths count] > 1)
            return NO;
        
        // Get item
        NSString *path = [paths objectAtIndex:0];
        if(folderPath != NULL) {
            *folderPath = [NSString stringWithString:path];
        }
        
        // Ensure is a folder
        NSError *error = nil;
        NSString *utiType = [[NSWorkspace sharedWorkspace] typeOfFile:path error:&error];
        
        // Error check
        if(error != nil) {
            NSLog(@"Drag Error: %@", [error localizedDescription]);
            return NO;
        }
        
        // Ensure is a folder
        if (![[NSWorkspace sharedWorkspace] type:utiType conformsToType:(id)kUTTypeFolder]) {
            return NO;
        }
        
        // Ensure is an xcode project folder
#warning implement me!!
    }
    
    return YES;
}

- (BOOL)isValidDraggableFolder:(id <NSDraggingInfo>)sender
{
    return [self isValidDraggableFolder:sender path:NULL];
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

- (NSString *)textStatusForState:(JHDropzoneState)state
{
    switch (state) {
        case JHDropzoneStateEnterGood:
            return @"Folder is good!";
            break;
        case JHDropzoneStateEnterBad:
            return @"Bad file!!";
            break;
        case JHDropzoneStateNormal:
        default:
            break;
    }
    return @"Drop a folder!";
}

-(void)setState:(JHDropzoneState)state
{
    _viewState = state;
    
    // Update image
    [_dropzoneImageView setImage:[self imageForState:_viewState]];

    // Update bubble text
    [_speechBubbleView setBubbleText:[self textStatusForState:_viewState]];
    
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
    lineDash[0] = 20.0;
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
    if(_viewState == JHDropzoneStateEnterGood) {
        [NSBezierPath setDefaultLineWidth:6.0];
        [[NSColor greenColor] set];
        [NSBezierPath strokeRect:frame];
    }
    else if(_viewState == JHDropzoneStateEnterBad) {
        [NSBezierPath setDefaultLineWidth:6.0];
        [[NSColor redColor] set];
        [NSBezierPath strokeRect:frame];
    }
    
    // Update speech bubble position
    CGRect speechBubbleRect = _speechBubbleView.frame;
    speechBubbleRect.origin.x = 0.5f *(self.bounds.size.width-speechBubbleRect.size.width);
    speechBubbleRect.origin.y = 0.5f * (self.bounds.size.height-speechBubbleRect.size.height)+100.0f;
    [_speechBubbleView setFrame:speechBubbleRect];
    
    // Update image position
    CGRect imageFrame = _dropzoneImageView.frame;
    imageFrame.origin.x = 0.5f * (self.bounds.size.width-imageFrame.size.width);
    imageFrame.origin.y = speechBubbleRect.origin.y-imageFrame.size.height;
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
