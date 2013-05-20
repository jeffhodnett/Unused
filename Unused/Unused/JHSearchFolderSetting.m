//
//  JHSearchFolderSetting.m
//  Unused
//
//  Created by Jeff Hodnett on 5/17/13.
//
//

#import "JHSearchFolderSetting.h"

@implementation JHSearchFolderSetting

@synthesize searchDirectoryPath=_searchDirectoryPath;

-(void)dealloc
{
    [_searchDirectoryPath release];
    
    [super dealloc];
}

@end
