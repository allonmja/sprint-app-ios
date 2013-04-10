//
//  CPWRLaunchScanViewController.h
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDK/ScanditSDKOverlayController.h"
#import "ScanditSDK/ScanditSDKBarcodePicker.h"

@interface CPWRLaunchScanViewController : UIViewController <ScanditSDKOverlayControllerDelegate>
{ }
@property (weak, nonatomic) IBOutlet UIButton *selectDocumentButton;

@end
