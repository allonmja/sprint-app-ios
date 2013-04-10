//
//  CPWRPrintViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRPrintViewController.h"
#import "CPWRButtonStyles.h"

#define RELEASE_PRINT_JOB_URL @"http://10.24.16.122/release_print_job.php"
#define MOVE_JOB_TO_PRINTER_URL @"http://10.24.16.122/move_print_job.php"

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


- (void)moveJobToPrinter
{
    
    self.printButton.hidden = true;
    
    NSString *printer = self.printerName;
    
    NSLog(@"Printer name: %@", printer);
    
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString: MOVE_JOB_TO_PRINTER_URL]];
    
    [request setHTTPMethod:@"POST"];
    
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
            
            _printStatusLabel.textColor = [UIColor blueColor];
            _printStatusLabel.text = @"Ready to Print";
        } else {
            
            NSLog(@"Failed to print Job!!! Please try again");
            _printStatusLabel.textColor = [UIColor redColor];
            _printStatusLabel.text = @"Unable to setup Printer Service.";
        }
        
    } else {
        NSLog(@"Error");
    }
    
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
    [super viewDidUnload];
}
@end
