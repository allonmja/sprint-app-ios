//
//  CPWRFirstViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/1/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRScanViewController.h"
#import "CPWRButtonStyles.h"
#import "CPWRDocumentsViewController.h"
#import "CompuwareUEM.h"

@interface CPWRScanViewController ()
{
    NSString *printName;
}

@end

@implementation CPWRScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CPWRButtonStyles *buttonDesigner = [[CPWRButtonStyles alloc] init];
    [buttonDesigner designButton: self.startScanButton];
    
    
    /*  Compuware UEM monitoring start scan action.  */
    [CompuwareUEM enterAction:@"Scan Time"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setQrCodeLabel:nil];
    [self setStartScanButton:nil];
    [self setResultImage:nil];
    [self setResultText:nil];
    [super viewDidUnload];
}
- (IBAction)scanButtonTapped:(id)sender
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader animated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    
    printName = symbol.data;
    NSLog(@"Printer name = %@", printName);
    
    
    // EXAMPLE: do something useful with the barcode data
    _resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    /*_resultImage.image =
    [info objectForKey: UIImagePickerControllerOriginalImage];*/
    
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    //CPWRDocumentsViewController *myNewVC = [[CPWRDocumentsViewController alloc] init];
    
    /*  Compuware UEM leaving start scan action  */
    [CompuwareUEM leaveAction:@"Scan Time"];
    
    if ([[self jobID] length] >0){
        [self performSegueWithIdentifier: @"printJob" sender: self];

    }else{
        [self performSegueWithIdentifier: @"documentSegue" sender: self];
    }
    
    // do any setup you need for myNewVC
    //[self presentModalViewController:myNewVC animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setPrinterName:printName];
    if ([[self jobID] length] >0){
        [[segue destinationViewController] setJobID:[self jobID]];
        [[segue destinationViewController] setJobName:[self jobName]];
    }
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancelled Scanner");
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [picker dismissModalViewControllerAnimated: YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return(YES);
}


@end
