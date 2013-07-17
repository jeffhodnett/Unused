//
//  JHResultsViewController.h
//  Unused
//
//  Created by Jeff Hodnett on 5/16/13.
//
//

#import <Cocoa/Cocoa.h>
#import "JHViewController.h"

@interface JHResultsViewController : JHViewController<NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *_results;
}

@property (assign) IBOutlet NSTableView *resultsTableView;

// Actions
-(IBAction)browseButtonSelected:(id)sender;
-(IBAction)startSearch:(id)sender;
-(IBAction)exportButtonSelected:(id)sender;

@end
