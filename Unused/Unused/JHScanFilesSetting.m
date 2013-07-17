//
//  JHScanFilesSetting.m
//  Unused
//
//  Created by Jeff Hodnett on 5/17/13.
//
//

#import "JHScanFilesSetting.h"

@implementation JHScanFilesSetting

@synthesize mCheckboxSelected;
@synthesize xibCheckbox;
@synthesize cppCheckbox;
@synthesize htmlCheckbox;
@synthesize mmCheckbox;
@synthesize plistCheckbox;
@synthesize cssCheckbox;

-(NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"m:%d ", mCheckboxSelected];
    [str appendFormat:@"xib:%d ", xibCheckbox];
    [str appendFormat:@"c++:%d ", cppCheckbox];
    [str appendFormat:@"html:%d ", htmlCheckbox];
    [str appendFormat:@"mm:%d ", mmCheckbox];
    [str appendFormat:@"plist:%d ", plistCheckbox];
    [str appendFormat:@"css:%d ", cssCheckbox];
    
    return str;
}

@end
