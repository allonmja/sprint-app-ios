//
//  CPWRLaunchScanViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRLaunchScanViewController.h"
#import "ScanditSDKBarcodePicker.h"
#import "CPWRButtonStyles.h"

#define kScanditSDKAppKey @"0n5YKmvcEeKbg0SURa+BjSHS57J4ZGY5u1UrOvyJncA"

@interface CPWRLaunchScanViewController ()

@end

@implementation CPWRLaunchScanViewController

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
    [buttonDesigner designButton: self.selectDocumentButton];
    
    [self launchScandit];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)launchScandit
{
    ScanditSDKBarcodePicker *picker = [[ScanditSDKBarcodePicker alloc] initWithAppKey: kScanditSDKAppKey];
    
    picker.overlayController.delegate = self;
    [picker startScanning];
    [self presentModalViewController:picker animated:YES];
    
}


- (void)scanditSDKOverlayController: (ScanditSDKOverlayController *)scanditSDKOverlayController
                     didScanBarcode:(NSDictionary *)barcodeResult
{
    
    NSString *barcodeString = [barcodeResult valueForKey:@"barcode"];
    NSNumber *number = [NSNumber numberWithInt:[barcodeString intValue]];
    NSLog(@"barcode string = %@", barcodeString);
    NSLog(@"number = %@", number);
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)scanditSDKOverlayController: (ScanditSDKOverlayController *)scanditSDKOverlayController
                didCancelWithStatus:(NSDictionary *)status
{
    
}

- (void)scanditSDKOverlayController: (ScanditSDKOverlayController *)scanditSDKOverlayController
                    didManualSearch:(NSString *)input
{

}

- (void)viewDidUnload {
    [self setSelectDocumentButton:nil];
    [super viewDidUnload];
}
@end
