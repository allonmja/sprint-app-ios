//
//  CPWRPrintersViewController.h
//  Sprint
//
//  Created by Vincent Sam on 4/1/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface CPWRPrintersViewController : UITableViewController <UISearchDisplayDelegate, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
    
    UIActivityIndicatorView *activityIndicator;
    
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;


@property (strong, nonatomic) NSMutableArray *filteredPrinters;
@property (nonatomic) NSString *jobID;
@property (nonatomic) NSString *jobName;
@property (nonatomic) NSString *printerName;


@end
