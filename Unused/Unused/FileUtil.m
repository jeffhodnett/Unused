//
//  FileUtil.m
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

#import "FileUtil.h"

@implementation FileUtil

+ (NSString *)stringFromFileSize:(int)fileSize {
    if (fileSize < 1023) {
        return([NSString stringWithFormat:@"%i bytes", fileSize]);
    }
    
    float floatSize = fileSize / 1024;
    if (floatSize < 1023) {
        return([NSString stringWithFormat:@"%1.1f KB", floatSize]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023) {
        return([NSString stringWithFormat:@"%1.1f MB", floatSize]);
    }
    
    floatSize = floatSize / 1024;
    return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

+ (NSArray *)imageFilesInDirectory:(NSString *)directoryPath {
    
    NSMutableArray *images = [NSMutableArray array];
    
    // jpg
    NSArray *jpg = [self searchDirectory:directoryPath forFiletype:@"jpg"];
    [images addObjectsFromArray:jpg];

    // jpeg
    NSArray *jpeg = [self searchDirectory:directoryPath forFiletype:@"jpeg"];
    [images addObjectsFromArray:jpeg];
    
    // png
    NSArray *png = [self searchDirectory:directoryPath forFiletype:@"png"];
    [images addObjectsFromArray:png];
    
    // gif
    NSArray *gif = [self searchDirectory:directoryPath forFiletype:@"gif"];
    [images addObjectsFromArray:gif];
    
    return images;
}

+ (NSArray *)searchDirectory:(NSString *)directoryPath forFiletype:(NSString *)filetype {
    // Create a find task
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/find"];
    
    // Search for all png files
    NSArray *argvals = [NSArray arrayWithObjects:directoryPath,@"-name",[NSString stringWithFormat:@"*.%@", filetype], nil];
    [task setArguments: argvals];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    
    // Run task
    [task launch];
    
    // Read the response
    NSData *data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    // See if we can create a lines array
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    return lines;
}

@end
