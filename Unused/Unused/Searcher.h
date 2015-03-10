//
//  Searcher.h
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

@class Searcher;

/**
 *  The searcher delegate
 */
@protocol SearcherDelegate <NSObject>

@optional
/**
 *  The searcher did begin searching
 *
 *  @param searcher The searcher object
 */
- (void)searcherDidStartSearch:(Searcher *)searcher;

/**
 *  The searcher did find an unused image during its search
 *
 *  @param searcher  The searcher object
 *  @param imagePath The unused image path
 */
- (void)searcher:(Searcher *)searcher didFindUnusedImage:(NSString *)imagePath;

/**
 *  The searcher did finish searching
 *
 *  @param searcher The searcher object
 *  @param results  The unused image path results
 */
- (void)searcher:(Searcher *)searcher didFinishSearch:(NSArray *)results;

@end

/**
 *  The searcher class
 *  Use this object to search for un-used image files in your xcode projects
 */
@interface Searcher : NSObject

/**
 *  The searcher delegate
 */
@property (assign) id <SearcherDelegate> delegate;

/**
 *  The project search path
 */
@property (copy) NSString *projectPath;

/**
 *  Include .m files in the search
 */
@property (nonatomic) BOOL mSearch;

/**
 *  Include .xib files in the search
 */
@property (nonatomic) BOOL xibSearch;

/**
 *  Include .storyboard files in the search
 */
@property (nonatomic) BOOL storyboardSearch;

/**
 *  Include .cpp files in the search
 */
@property (nonatomic) BOOL cppSearch;

/**
 *  Include .h files in the search
 */
@property (nonatomic) BOOL headerSearch;

/**
 *  Include .html files in the search
 */
@property (nonatomic) BOOL htmlSearch;

/**
 *  Include .mm files in the search
 */
@property (nonatomic) BOOL mmSearch;

/**
 *  Include .plist files in the search
 */
@property (nonatomic) BOOL plistSearch;

/**
 *  Include .css files in the search
 */
@property (nonatomic) BOOL cssSearch;

/**
 *  Include .swift files in the search
 */
@property (nonatomic) BOOL swiftSearch;

/**
 *  Include image enum variant filtering in the search
 */
@property (nonatomic) BOOL enumFilter;

/**
 *  Start the search
 */
- (void)start;

/**
 *  Stop the search
 */
- (void)stop;

@end
