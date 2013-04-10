//
//  CPWRDocumentsViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/2/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRDocumentsViewController.h"
#import "CPWRDocumentsTableCell.h"
#import "CPWRPrintViewController.h"
#import "CompuwareUEM.h"

#define DOCUMENT_LIST_URL @"http://10.24.16.122/show_active_jobs.php"
#define DOCUMENT_CANCEL_URL @"http://10.24.16.122/cancel_print_job.php"
#define kFilename @"userPrefs.plist"
#define kRecents @"recentPrinters.plist"

@interface CPWRDocumentsViewController ()
{
    NSMutableArray *documents;
    NSUserDefaults *userPrefs;
    NSString *userID;
}

@end

@implementation CPWRDocumentsViewController

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
    
    
    // [self refreshTables];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self refreshTables];
    [self retrieveRecentPrinters];
    [self addToRecentPrinters];
}


- (void) retrieveRecentPrinters
{
    
    if(!self.recentPrinters)
    {
        self.recentPrinters = [[NSMutableArray alloc] init];
    }
    [self.recentPrinters removeAllObjects];
    
    NSString *filePath = [self recentPrinterFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        
        NSString *name;
        NSString *location;
        NSString *printType = @"bw";
        NSDictionary *printerRecord;
        
        for(NSDictionary *printer in array)
        {
            name = printer[@"name"];
            location = printer[@"location"];
            name = ([name length] > 0) ? name : @"Unknown";
            location = ([location length] > 0 ) ? location  : @"Unknown";
            
            
            printerRecord = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name",  location, @"location",
                             printType, @"type", nil];
            [self.recentPrinters addObject:printerRecord];
            
        }
    }
    
    
}
- (void) addToRecentPrinters
{
    
    int i =0;
    for(NSDictionary *printer in self.recentPrinters)
    {
        if ([self.printerName isEqualToString:printer[@"name"]]){
            return;
        }
        i++;
        if (i>=5){
            [self.recentPrinters removeLastObject];
            [self saveRecentPrinters];
            return;
        }
    }
    NSString *location;
    NSString *printType=@"bw";
    NSDictionary *printerRecord = [[NSDictionary alloc] initWithObjectsAndKeys: self.printerName, @"name",  location, @"location", printType, @"type", nil];
    [self.recentPrinters insertObject:printerRecord atIndex:0];
    [self saveRecentPrinters];
    
    
}


- (void)saveRecentPrinters
{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSLog(@"Datapath = %@", [self dataFilePath]);
    [array addObjectsFromArray:self.recentPrinters];
    [array writeToFile:[self recentPrinterFilePath] atomically:YES];
    
}

- (NSString *)recentPrinterFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kRecents];
}

- (void)refreshTables
{
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
    
    [self dataPersistence];
    [self retrieveDocuments];
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}


- (void)dataPersistence
{
    userID = [userPrefs objectForKey:@"userNetworkID"];
    
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        userID = [array objectAtIndex:0];
    }
}

- (void)retrieveDocuments
{
    if (!documents) {
        documents  = [[NSMutableArray alloc] init];
    }
    [documents removeAllObjects];
    [self.tableView reloadData];
    
    // Prepare for the post
    if([self prepareForPost])
    {
        // Get filtered documents
        [self setFilteredDocuments:[NSMutableArray arrayWithCapacity:documents.count]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Documents
- (void)insertNewObject:(id)sender andCounter:(int)i
{
    [documents insertObject:sender atIndex:i];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        return [self.filteredDocuments count];
    }
    
    return documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"documentsCell";
    CPWRDocumentsTableCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) {
        cell = [[CPWRDocumentsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        [self setDocumentImage:self.filteredDocuments[indexPath.row][@"type"] withImageView:cell.documentImageView];
        cell.documentNameLabel.text = self.filteredDocuments[indexPath.row][@"name"];
        cell.documentAuthorLabel.text = self.filteredDocuments[indexPath.row][@"author"];
        [self.tableView setRowHeight:93];
        
    } else {
        [self setDocumentImage:documents[indexPath.row][@"type"] withImageView:cell.documentImageView];
        cell.documentNameLabel.text = documents[indexPath.row][@"name"];
        cell.documentAuthorLabel.text = documents[indexPath.row][@"author"];
    }
    
    return cell;
}

- (void)setDocumentImage:(NSString *)type withImageView:(UIImageView *)image
{
    if([type isEqualToString:@"word"])
        [image setImage: [UIImage imageNamed:@"worddoc.png"]];
    else if([type isEqualToString:@"ppt"])
        [image setImage: [UIImage imageNamed:@"pptdoc.png"]];
    else if([type isEqualToString:@"excel"])
        [image setImage: [UIImage imageNamed:@"exceldoc.png"]];
    else if ([type isEqualToString:@"pdf"])
        [image setImage: [UIImage imageNamed:@"pdfdoc.png"]];
    else
        [image setImage: [UIImage imageNamed:@"worddoc.png"]];
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString* jobId = documents[indexPath.row][@"job_id"];
        [self cancelJobPost:jobId];
        [documents removeObject:documents[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"printJob"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setJobID:documents[indexPath.row][@"job_id"]];
        [[segue destinationViewController] setPrinterName:self.printerName];
        NSLog(@"printer name %@", self.printerName);
        
    }
}

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

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


- (void)filterContentForSearchText:(NSString*)searchText
{
	[self.filteredDocuments removeAllObjects];
	
	for (NSDictionary *d in documents)
	{
        NSComparisonResult result = [d[@"name"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (result == NSOrderedSame) [self.filteredDocuments addObject:d];
	}
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}


- (BOOL)prepareForPost
{
    
    // Compuware UEM event.  Monitoring loading jobs.
    [CompuwareUEM enterAction:@"Load Jobs"];
    
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString: DOCUMENT_LIST_URL]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *username = userID;
    
    NSString *post = [NSString stringWithFormat:@"user_name=%@", username];
    NSLog(@"post value = %@", post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    NSError *error = [[NSError alloc] init];
    
    // get response
    NSHTTPURLResponse *urlResponse = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Response code: %d", [urlResponse statusCode]);
    
    if ([urlResponse statusCode] >=200 && [urlResponse statusCode] <300)
    {
        //NSLog(@"jsonDict %@", jsonDict);
        [self populateTable:jsonDict];
        return YES;
    } else {
        NSLog(@"Error");
    }
    return  NO;
}

- (BOOL) cancelJobPost:(NSString*)job_id
{
    
    // Compuware UEM event.  Monitoring loading jobs.
    [CompuwareUEM enterAction:@"Load Jobs"];
    
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString: DOCUMENT_CANCEL_URL]];
    
    [request setHTTPMethod:@"POST"];
    
    
    NSString *post = [NSString stringWithFormat:@"job_id=%@", job_id];
    //NSLog(@"job_id = %@", job_id);
    NSLog(@"cancel value = %@", post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    NSError *error = [[NSError alloc] init];
    
    // get response
    NSHTTPURLResponse *urlResponse = nil;
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse
                                      error:&error];
    
    
    NSLog(@"Response code: %d", [urlResponse statusCode]);
    
    if ([urlResponse statusCode] >=200 && [urlResponse statusCode] <300)
    {
        
    } else {
        NSLog(@"Error");
    }
    return  NO;
    
}

- (void)populateTable:(NSDictionary *)jsonObject
{
    NSDictionary *documentRecord;
    
    NSString *name;
    NSString *author;
    NSString *mimeType;
    NSString *job_id;
    
    int i = 0;
    
    for( NSDictionary *doc in jsonObject)
    {
        mimeType = doc[@"file_type"];
        name = doc[@"job_title"];
        author = doc[@"user_name"];
        job_id = doc[@"job_id"];
        
        documentRecord = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name",  author, @"author",
                          mimeType, @"type", job_id, @"job_id", nil];
        
        [self insertNewObject:documentRecord andCounter:i];
        i++;
    }
    
    NSLog(@"Count of document: %i", documents.count);
    
    if(documents.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Documents in queue", @"AlertView")
                                                            message:NSLocalizedString(@"Send document(s) to SPRINT printer on your computer.", @"AlertView")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    [CompuwareUEM leaveAction:@"Load Jobs"];
    
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
