//
//  UnusedAppDelegate.h
//  Unused
//
//  Created by Jeff Hodnett on 19/11/2011.
//  Copyright 2011 Seamonster Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UnusedAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
@private
    
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

// Outlets
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *resultsTableView;
@property (assign) IBOutlet NSProgressIndicator *processIndicator;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSButton *exportButton;
@property (assign) IBOutlet NSButton *mCheckbox;
@property (assign) IBOutlet NSButton *xibCheckbox;
@property (assign) IBOutlet NSButton *sbCheckbox;
@property (assign) IBOutlet NSButton *cppCheckbox;
@property (assign) IBOutlet NSButton *headerCheckbox;
@property (assign) IBOutlet NSButton *htmlCheckbox;
@property (assign) IBOutlet NSButton *mmCheckbox;
@property (assign) IBOutlet NSButton *plistCheckbox;
@property (assign) IBOutlet NSButton *enumCheckbox;
@property (assign) IBOutlet NSButton *cssCheckbox;
@property (assign) IBOutlet NSButton *browseButton;
@property (assign) IBOutlet NSTextField *pathTextField;
@property (assign) IBOutlet NSButton *searchButton;

// The search directory path
@property(nonatomic, retain) NSString *searchDirectoryPath;

// Actions
-(IBAction)browseButtonSelected:(id)sender;
-(IBAction)startSearch:(id)sender;
-(IBAction)exportButtonSelected:(id)sender;

// Methods
-(NSArray *)pngFilesAtDirectory:(NSString *)directoryPath;
-(BOOL)isValidImageAtPath:(NSString *)imagePath;
-(int)occurancesOfImageNamed:(NSString *)imageName atDirectory:(NSString *)directoryPath inFileExtensionType:(NSString *)extension;

-(void)addNewResult:(NSString *)pngPath;

// Handle the ui updates
-(void)setUIEnabled:(BOOL)state;

-(NSString *)stringFromFileSize:(int)theSize;

@end
