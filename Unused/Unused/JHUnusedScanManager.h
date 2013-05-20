//
//  JHUnusedScanManager.h
//  Unused
//
//  Created by Jeff Hodnett on 5/17/13.
//
//

#import <Foundation/Foundation.h>

@interface JHUnusedScanManager : NSObject
{
    NSString *_searchDirectoryPath;
    
    // Arrays
    NSArray *_pngFiles;
    NSMutableArray *_results;
    NSMutableArray *_retinaImagePaths;
    
    NSOperationQueue *_queue;
    BOOL isSearching;
	
	// Stores the file data to avoid re-reading files, using a lock to make it thread-safe.
	NSMutableDictionary *_fileData;
	NSLock *_fileDataLock;
}

+ (id)sharedManager;

// Methods
-(NSArray *)pngFilesAtDirectory:(NSString *)directoryPath;
-(BOOL)isValidImageAtPath:(NSString *)imagePath;
-(int)occurancesOfImageNamed:(NSString *)imageName atDirectory:(NSString *)directoryPath inFileExtensionType:(NSString *)extension;

-(void)addNewResult:(NSString *)pngPath;

@end
