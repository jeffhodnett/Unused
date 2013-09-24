//
//  JHButton.m
//  Unused
//
//  Created by Jeff Hodnett on 9/23/13.
//
//

#import "JHButton.h"

@implementation JHButton

+(JHButton *)buttonWithText:(NSString *)text
{
    JHButton *btn = [[[JHButton alloc] initWithFrame:NSMakeRect(0, 0, 100.0f, 50.0f)] autorelease];
    [btn setTitle:text];
    
    return btn;
}

@end
