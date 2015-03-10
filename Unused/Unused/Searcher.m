//
//  Searcher.m
//  Unused
//  https://github.com/jeffhodnett/Unused
//
//  Copyright (c) 2015 Jeff Hodnett
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "Searcher.h"
#import "FileUtil.h"

@interface Searcher () {
@private
    
    // Arrays
    NSArray *_projectImageFiles;
    NSMutableArray *_results;
    NSMutableArray *_retinaImagePaths;
    
    NSOperationQueue *_queue;
    BOOL isSearching;
    
    // Stores the file data to avoid re-reading files, using a lock to make it thread-safe.
    NSMutableDictionary *_fileData;
    NSLock *_fileDataLock;
}

@end

@implementation Searcher

- (instancetype)init {
    if (self = [super init]) {
        
        // Setup the results array
        _results = [[NSMutableArray alloc] init];
        
        // Setup the retina images array
        _retinaImagePaths = [[NSMutableArray alloc] init];
        
        // Setup the queue
        _queue = [[NSOperationQueue alloc] init];
        
        // Setup data lock
        _fileData = [NSMutableDictionary new];
        _fileDataLock = [NSLock new];
    }
    return self;
}

- (void)start {
 
    // Start the search
    NSInvocationOperation *searchOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runImageSearch:) object:self.projectPath];
    [_queue addOperation:searchOperation];
}

- (void)stop {
#warning implement me!
}

- (void)runImageSearch:(NSString *)searchPath {
    // Start the search
    if (self.delegate && [self.delegate respondsToSelector:@selector(searcherDidStartSearch:)]) {
        [self.delegate searcherDidStartSearch:self];
    }
    
    // Find all the image files in the folder
    _projectImageFiles = [FileUtil imageFilesInDirectory:searchPath];
    
    NSArray *imageFiles = _projectImageFiles;
    if (self.enumFilter) {
        NSMutableArray *mutablePngFiles = [NSMutableArray arrayWithArray:imageFiles];
        
        // Trying to filter image names like: "Section_0.png", "Section_1.png", etc (these names can possibly be created by [NSString stringWithFormat:@"Section_%d", (int)] constructions) to just "Section_" item
        for (NSInteger index = 0, count = [mutablePngFiles count]; index < count; index++) {
            NSString *imageName = [mutablePngFiles objectAtIndex:index];
            NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[_-].*\\d.*.png" options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *newImageName = [regExp stringByReplacingMatchesInString:imageName options:NSMatchingReportProgress range:NSMakeRange(0, [imageName length]) withTemplate:@""];
            if (newImageName) {
                [mutablePngFiles replaceObjectAtIndex:index withObject:newImageName];
            }
        }
        
        // Remove duplicates and update pngFiles array
        imageFiles = [[NSSet setWithArray:mutablePngFiles] allObjects];
    }
    
    // Setup all the retina image firstly
    // DISCUSSION: performance vs extensibility. Is a n^2 loop better for extensibility or is a large if statement with better effency
    for (NSString *pngPath in _projectImageFiles) {
        NSString *imageName = [pngPath lastPathComponent];
        
        // Does the image have a retina version
        for (NSString *retinaRangeString in [self supportedRetinaImagePostfixes]) {
            NSRange retinaRange = [imageName rangeOfString:retinaRangeString];
            if (retinaRange.location != NSNotFound) {
                // Add to retina image paths
                [_retinaImagePaths addObject:pngPath];
                break;
            }
        }
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Now loop and check
    [imageFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_group_async(group, queue, ^{
            NSString *imagePath = (NSString *)obj;
            
            BOOL isImagePathEmpty = [imagePath isEqualToString:@""];
            if (!isImagePathEmpty) {
                
                // Check that it's not a retina image or reserved image name
                BOOL isValidImage = [self isValidImageAtPath:imagePath];
                if (isValidImage) {
                    // Grab the file name
                    NSString *imageName = [imagePath lastPathComponent];

                    // Settings items
                    NSArray *settingsItems = [self searchSettings];
                    BOOL isSearchCancelled = NO;
                    for (NSString *extension in settingsItems) {
     
                        // Run the check
                        if (!isSearchCancelled && [self occurancesOfImageNamed:imageName atDirectory:searchPath inFileExtensionType:extension]) {
                            isSearchCancelled = YES;
                        }
                    }
                    
                    // Is it not found - update results
                    if (!isSearchCancelled)
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (self.delegate && [self.delegate respondsToSelector:@selector(searcher:didFindUnusedImage:)]) {
                                [self.delegate searcher:self didFindUnusedImage:imagePath];
                            }
                            
                        });
                }
            }
        });
    }];
    
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{

            [_results sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(searcher:didFinishSearch:)]) {
                [self.delegate searcher:self didFinishSearch:_results];
            }
            
            isSearching = NO;
            [_fileData removeAllObjects];
        });
    });
}

- (NSArray *)searchSettings {
    
    NSMutableArray *settings = [NSMutableArray array];
    
    if (self.mSearch) {
        [settings addObject:@"m"];
    }
    
    if (self.xibSearch) {
        [settings addObject:@"xib"];
    }

    if (self.storyboardSearch) {
        [settings addObject:@"storyboard"];
    }
    
    if (self.cppSearch) {
        [settings addObject:@"cpp"];
    }
    
    if (self.headerSearch) {
        [settings addObject:@"h"];
    }
    
    if (self.htmlSearch) {
        [settings addObject:@"html"];
    }

    if (self.mmSearch) {
        [settings addObject:@"mm"];
    }

    if (self.plistSearch) {
        [settings addObject:@"plist"];
    }
    
    if (self.cssSearch) {
        [settings addObject:@"css"];
    }
    
    if (self.swiftSearch) {
        [settings addObject:@"swift"];
    }

    return settings;
}

- (NSArray *)supportedRetinaImagePostfixes {
    return @[@"@2x", @"@3x"];
}

- (BOOL)isValidImageAtPath:(NSString *)imagePath {
    // Grab image name
    NSString *imageName = [imagePath lastPathComponent];
    
    // Check if is retina
    for (NSString *retinaRangeString in [self supportedRetinaImagePostfixes]) {
        NSRange retinaRange = [imageName rangeOfString:retinaRangeString];
        if (retinaRange.location != NSNotFound) {
            return NO;
        }
    }
    
    // Check for reserved names
    BOOL isThirdPartyBundle = [imagePath rangeOfString:@".bundle"].length > 0;
    BOOL isNamedDefault = [imageName isEqualToString:@"Default.png"];
    BOOL isNamedIcon = [imageName isEqualToString:@"Icon.png"] || [imageName isEqualToString:@"Icon@2x.png"] || [imageName isEqualToString:@"Icon-72.png"];
    BOOL isUniversalImage = [imagePath rangeOfString:@"~ipad" options:NSCaseInsensitiveSearch].length > 0;
    
    return !(isThirdPartyBundle && isNamedDefault && isNamedIcon && isUniversalImage);
}

- (int)occurancesOfImageNamed:(NSString *)imageName atDirectory:(NSString *)directoryPath inFileExtensionType:(NSString *)extension {
    [_fileDataLock lock];
    
    NSData *data = [_fileData objectForKey:directoryPath];
    if (!data) {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: @"/bin/sh"];
        
        // Setup the call
        NSString *cmd = [NSString stringWithFormat:@"for filename in `find %@ -name '*.%@'`; do cat $filename 2>/dev/null | grep -o %@ ; done", directoryPath, extension, [imageName stringByDeletingPathExtension]];
        NSLog(@"%@", cmd);
        NSArray *argvals = [NSArray arrayWithObjects: @"-c", cmd, nil];
        [task setArguments: argvals];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        [task launch];
        
        // Read the response
        NSFileHandle *file = [pipe fileHandleForReading];
        data = [file readDataToEndOfFile];
        NSString *key = [NSString stringWithFormat:@"%@/%@",directoryPath, imageName];
        
        [_fileData setObject:data forKey:key];
    }
    
    [_fileDataLock unlock];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Calculate the count
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
    int count = 0;
    while ([scanner scanUpToCharactersFromSet:newline intoString:nil]) {
        count++;
    }
    
    return count;
}

@end
