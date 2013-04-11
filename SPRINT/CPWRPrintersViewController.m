//
//  CPWRPrintersViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/1/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRPrintersViewController.h"
#import "CPWRPrintersTableCell.h"
#import "CPWRDocumentsViewController.h"
#import "CompuwareUEM.h"

#define PRINTER_LIST_URL @"http://10.24.16.122/show_printers.php"
#define kFilename @"recentPrinters.plist"

@interface CPWRPrintersViewController ()
{
    NSMutableArray *printers;
    NSMutableArray *recentPrinters;
    NSURLConnection *_connection;
    NSString *dataPath;
    NSMutableData *_data;
}

@end

@implementation CPWRPrintersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self refreshTables];

    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshTables];

    [super viewWillAppear:animated];
    
    
}

- (void)retrievePrinters
{
    
    // Compuware UEM event.  Monitoring load time for printers
    
    [CompuwareUEM enterAction:@"Load Printers"];
    
    if (!printers) {
        printers = [[NSMutableArray alloc] init];
    }

    /*  Initiate the filtered printers list  */
    [self setFilteredPrinters:[NSMutableArray arrayWithCapacity:printers.count]];
    
    
    /*  Set up the request  */
    NSURL *url = [NSURL URLWithString: PRINTER_LIST_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    _data = [NSMutableData data];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void) retrieveRecentPrinters
{
    if(!recentPrinters)
    {
        recentPrinters = [[NSMutableArray alloc] init];
    }
    [self.tableView reloadData];
    
    /*  Load recent printers from file in storage  */
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        
        NSString *name;
        NSString *location;
        NSString *printType = @"bw";
        NSDictionary *printerRecord;
        
        int i =0;
        for(NSDictionary *printer in array)
        {
            name = printer[@"name"];
            location = printer[@"location"];
            
            
            name = ([name length] > 0) ? name : @"Unknown";
            location = ([location length] > 0 ) ? location  : @"Unknown";
            
            
            printerRecord = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name",  location, @"location",
                             printType, @"type", nil];
            [self insertRecentPrinter:printerRecord andCounter:i];

            i++;

        }
    }
    
    [self.tableView reloadData];


    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}


- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
    
    NSError* error;
    NSArray* jsonObject = [NSJSONSerialization
                           JSONObjectWithData:_data //1
                           options:0
                           error:&error];
    
    
    NSDictionary *printerRecord;
    NSString *name;
    NSString *location;
    NSString *printType = @"bw";
    
    /*  Loop through the JSON object to create printers  */
    int i = 0;
    for(NSDictionary *printer in jsonObject)
    {
        name = printer[@"printer_name"];
        location = printer[@"port_name"];
        
        
        name = ([name length] > 0) ? name : @"Unknown";
        location = ([location length] > 0 ) ? location  : @"Unknown";
        
        
        printerRecord = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name",  location, @"location",
                         printType, @"type", nil];
        [self insertNewObject:printerRecord andCounter:i];
        i++;
    }

    if (recentPrinters == nil){
        recentPrinters = [[NSMutableArray alloc] init];
    }
    
    /*  Finally, retrieve the user's recent printers  */
    [self retrieveRecentPrinters];
    
    if(printers.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Printers Available", @"AlertView")
                                                            message:NSLocalizedString(@"There are currently no printers available.", @"AlertView")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    // Compuware UEM event.  Leaving load printers
    
    [CompuwareUEM leaveAction:@"Load Printers"];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return @"All Printers";
            break;
        case 0:
            return @"Recent Printers";
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - Load Printers
- (void)insertNewObject:(id)sender andCounter:(int)i
{
    [printers insertObject:sender atIndex:i];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertRecentPrinter:(id)sender andCounter:(int)i
{
    
    [recentPrinters insertObject:sender atIndex:i];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 1:
            if(tableView == [[self searchDisplayController] searchResultsTableView])
            {
                return [self.filteredPrinters count];
            }
            
            return printers.count;
            break;
            
        case 0:
            return recentPrinters.count;
            break;
        default:
            return 0;
            break;
    }
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"printersCell";
    CPWRPrintersTableCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) {
        cell = [[CPWRPrintersTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        if (indexPath.section==1 && self.filteredPrinters.count > 0){
            [self setPrinterImage:self.filteredPrinters[indexPath.row][@"type"] withImageView:cell.printerImageView];
            //cell.printerLocationLabel.text   = self.filteredPrinters[indexPath.row][@"location"];
            cell.printerNameLabel.text      = self.filteredPrinters[indexPath.row][@"name"];
            cell.printerNameLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.printerNameLabel.numberOfLines = 2;
            [self.tableView setRowHeight:90];
        }
    } else {
        switch (indexPath.section) {
            case 1:
                [self setPrinterImage:printers[indexPath.row][@"type"] withImageView:cell.printerImageView];
                cell.printerLocationLabel.text   = printers[indexPath.row][@"location"];
                cell.printerNameLabel.text      = printers[indexPath.row][@"name"];
                cell.printerNameLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.printerNameLabel.numberOfLines = 2;
                break;
                
            case 0:
                [self setPrinterImage:printers[indexPath.row][@"type"] withImageView:cell.printerImageView];
                cell.printerLocationLabel.text   = recentPrinters[indexPath.row][@"location"];
                cell.printerNameLabel.text      = recentPrinters[indexPath.row][@"name"];
                cell.printerNameLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.printerNameLabel.numberOfLines = 2;
                break;
            default:
                break;
        }

    }
    [self.tableView setRowHeight:90];
    return cell;
}

- (void)setPrinterImage:(NSString *)type withImageView:(UIImageView *)image
{
    if([type isEqualToString:@"bw"])
        [image setImage: [UIImage imageNamed:@"blackwhiteprinter.png"]];
    else
        [image setImage: [UIImage imageNamed:@"colorprinter.png"]];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        switch (indexPath.section) {
            case 0:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                break;
            case 1:
                
                break;
                
            default:
                break;
        }

        
    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	[self.filteredPrinters removeAllObjects];
	
	for (NSDictionary *p in printers)
	{
        NSComparisonResult result = [p[@"name"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (result == NSOrderedSame) [self.filteredPrinters addObject:p];
	}
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectDocs"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSLog(@"Section index = %i", indexPath.section);
        
        switch (indexPath.section) {
            case 0:
                if(recentPrinters.count > 0)
                    [[segue destinationViewController] setPrinterName:recentPrinters[indexPath.row][@"name"]];
                else
                   [[segue destinationViewController] setPrinterName:printers[indexPath.row][@"name"]]; 
                break;
            case 1:
                [[segue destinationViewController] setPrinterName:printers[indexPath.row][@"name"]];

                break;
                
            default:
                //[[segue destinationViewController] setPrinterName:self.filteredPrinters[indexPath.row][@"name"]];
                break;
        }
        
    }

    
}


- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}



- (void)refreshTables
{
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
    
    [recentPrinters removeAllObjects];
    [printers removeAllObjects];
    
    
    /*  Load all the printers */
    [self retrievePrinters];
    [self.tableView reloadData];
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}



@end
