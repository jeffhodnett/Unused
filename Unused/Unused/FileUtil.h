//
//  FileUtil.h
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

#import <Foundation/Foundation.h>

/**
 *  File util helper class
 */
@interface FileUtil : NSObject

/**
 *  Return the nice formatted string for a file size
 *  i.e input = 1024   output = 1 KB
 *
 *  @param fileSize The file size integer
 *
 *  @return The formatted string descriptor for the size value
 */
+ (NSString *)stringFromFileSize:(int)fileSize;

/**
 *  Return all the image paths in the provided directory
 *
 *  This includes searching for image files like
 *  .jpg, .jpeg, .png, .gif
 *
 *  @param directoryPath The search path
 *
 *  @return The array of image paths
 */
+ (NSArray *)imageFilesInDirectory:(NSString *)directoryPath;

@end
