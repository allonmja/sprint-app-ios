//
//  CPWRPrintViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRPrintViewController.h"
#import "CPWRButtonStyles.h"
#import "CompuwareUEM.h"

#define kFilename @"userPrefs.plist"
#define RELEASE_PRINT_JOB_URL @"http://10.24.16.122/release_print_job.php"
#define MOVE_JOB_TO_PRINTER_URL @"http://10.24.16.122/move_print_job.php"
#define kRecents @"recentPrinters.plist"


@interface CPWRPrintViewController ()

@end

@implementation CPWRPrintViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
    CPWRButtonStyles *buttonDesigner = [[CPWRButtonStyles alloc] init];
    [buttonDesigner designButton: self.printButton];
    
    [self moveJobToPrinter];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [[self locationLabel] setText:[NSString stringWithFormat: @"Printer: \n%@", self.printerName]];
    [[self documentLabel] setText:[NSString stringWithFormat: @"Document: \n%@", self.jobName]];
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
    
    
    // Check if we have a printer name.  This will vary depending on what we've segued from
    if (self.printerName.length == 0)
    {
        return;
    }
    
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

- (void)moveJobToPrinter
{
    
    self.printButton.hidden = true;
    
    NSString *printer = self.printerName;
    
    NSLog(@"Printer name: %@", printer);
    
    
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString: MOVE_JOB_TO_PRINTER_URL]];
    
    [request setHTTPMethod:@"POST"];
    
    // Compuware UEM event. Entering print job
    [CompuwareUEM enterAction:@"Print Job"];
    
    NSString *jID = self.jobID;
    
    NSString *post = [NSString stringWithFormat:@"job_id=%@&printer_name=%@", jID, printer];
    NSLog(@"Move Job Post Values = %@", post);
    
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
    
    NSString *status = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Response code: %d", [urlResponse statusCode]);
    
    
    if ([urlResponse statusCode] >=200 && [urlResponse statusCode] <300)
    {
        NSLog(@"status return %@", status);
        
        if ([status intValue] == 0){
            
            self.printButton.hidden = false;
            
            NSString *username = @"";
            
            NSString *filePath = [self dataFilePath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
                username = [array objectAtIndex:0];
            }
            
            [CompuwareUEM reportEvent:[NSString stringWithFormat:@"Username - %@", username]];
            [CompuwareUEM reportEvent: [NSString stringWithFormat: @"Printer - %@", self.printerName]];
            [CompuwareUEM leaveAction:@"Print Job"];
            
            
            _printStatusLabel.textColor = [UIColor blueColor];
            _printStatusLabel.text = @"Ready to Print";
        } else {
            
            [CompuwareUEM reportEvent:@"Print Job - Failed"];
            [CompuwareUEM leaveAction:@"Print Job"];
            
            NSLog(@"Failed to print Job!!! Please try again");
            _printStatusLabel.textColor = [UIColor redColor];
            _printStatusLabel.text = @"Unable to setup Printer Service.";
        }
        
    } else {
        NSLog(@"Error");
    }
    
}


- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)prepareForPost
{
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString: RELEASE_PRINT_JOB_URL]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *jID = self.jobID;
    
    NSString *post = [NSString stringWithFormat:@"job_id=%@", jID];
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
    
    NSString *status = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Response code: %d", [urlResponse statusCode]);
    
    if ([urlResponse statusCode] >=200 && [urlResponse statusCode] <300)
    {
        NSLog(@"status return %@", status);
        
        if ([status intValue] == 0){
            NSLog(@"Success!!!");
            
            _printStatusLabel.textColor = [UIColor greenColor];
            _printStatusLabel.text = @"SUCCESS";
            
            
            
            
        } else {
            NSLog(@"Failed to print Job!!! Please try again");
            _printStatusLabel.textColor = [UIColor redColor];
            _printStatusLabel.text = @"Failed to print Job!!!";
        }
        
    } else {
        NSLog(@"Error");
    }
}



- (IBAction)printBtnClicked:(id)sender
{
    [self prepareForPost];
}

- (void)viewDidUnload {
    [self setPrintStatusLabel:nil];
    [self setPrintButton:nil];
    [self setDocumentLabel:nil];
    [self setLocationLabel:nil];
    [super viewDidUnload];
}
@end
