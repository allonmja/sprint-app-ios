//
//  CPWRMainTabsController.m
//  Sprint
//
//  Created by Vincent Sam on 4/2/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRMainTabsController.h"
#import "CPWRScanViewController.h"

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
@end
