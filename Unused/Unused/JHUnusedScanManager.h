//
//  JHUnusedScanManager.h
//  Unused
//
//  Created by Jeff Hodnett on 5/17/13.
//
//

#import <Foundation/Foundation.h>
#import "JHScanSetting.h"

@class JHUnusedScanManager;

@protocol JHUnusedScanManagerDelegate <NSObject>

@optional

-(void)scanManagerDidStartScan:(JHUnusedScanManager *)manager;
-(void)scanManager:(JHUnusedScanManager *)manager didFindResult:(NSString *)result;
-(void)scanManager:(JHUnusedScanManager *)manager finishedScanWithResults:(NSArray *)results;
-(void)scanManager:(JHUnusedScanManager *)manager didFailWithError:(NSError *)error;

@end

@interface JHUnusedScanManager : NSObject
{    
    // Settings
    NSMutableArray *_settings;
    
    // Arrays
    NSArray *_pngFiles;
    NSMutableArray *_results;
    NSMutableArray *_retinaImagePaths;
    
    NSOperationQueue *_queue;
	
	// Stores the file data to avoid re-reading files, using a lock to make it thread-safe.
	NSMutableDictionary *_fileData;
	NSLock *_fileDataLock;
}

@property(nonatomic, assign) id<JHUnusedScanManagerDelegate> delegate;

+ (id)sharedManager;

// Methods
- (void)addSetting:(JHScanSetting *)setting atIndex:(NSInteger)index;

- (void)startScan;
- (void)cancelScan;

- (NSArray *)results;

@end
