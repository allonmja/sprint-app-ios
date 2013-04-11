//
//  CPWRDocumentsViewController.h
//  Sprint
//
//  Created by Vincent Sam on 4/2/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface CPWRDocumentsViewController : UITableViewController <UISearchDisplayDelegate, UIAlertViewDelegate, EGORefreshTableHeaderDelegate>
{
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
    
    UIActivityIndicatorView *activityIndicator;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property (strong, nonatomic) NSMutableArray *filteredDocuments;
@property NSMutableArray *recentPrinters;
@property (nonatomic) NSString *printerName;

@end
