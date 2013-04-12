//
//  CPWRMainTabsController.m
//  Sprint
//
//  Created by Vincent Sam on 4/2/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRMainTabsController.h"
#import "CPWRScanViewController.h"

#define kFilename @"userPrefs.plist"

@interface CPWRMainTabsController ()

@end

@implementation CPWRMainTabsController

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
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self checkUserNetworkID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanBtnClicked:(id)sender
{
   
    self.tabBarController.selectedIndex = 0;
    
    NSLog(@"scan button click");
    
    /* ScanditSDKBarcodePicker *picker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"0n5YKmvcEeKbg0SURa+BjSHS57J4ZGY5u1UrOvyJncA"];
    
    picker.overlayController.delegate = self;
    [picker startScanning];
    [self presentModalViewController:picker animated:YES];*/
    
}


- (void)checkUserNetworkID
{
    NSString *username = @"";
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        username = [array objectAtIndex:0];
    }
    
    if([username isEqualToString:@""])
    {
        NSLog(@"Redirect user to preferences view");
        
        //CPWRPrefsViewController *prefsView = [[CPWRPrefsViewController alloc] init];
        //prefsView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self performSegueWithIdentifier: @"prefencesSegue" sender: self];
        
        // do any setup you need for myNewVC
        //[self presentModalViewController:prefsView animated:YES];
        
    }else{
        NSLog(@"User is signed in");
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}
- (void)viewDidUnload {
    [self setPreferencesButton:nil];
    [super viewDidUnload];
}
@end
