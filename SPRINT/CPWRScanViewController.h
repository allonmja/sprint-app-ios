//
//  CPWRFirstViewController.h
//  Sprint
//
//  Created by Vincent Sam on 4/1/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface CPWRScanViewController : UIViewController <ZBarReaderDelegate>

@property (weak, nonatomic) IBOutlet UITextView *qrCodeLabel;


@property (weak, nonatomic) IBOutlet UIButton *startScanButton;

@property (weak, nonatomic) IBOutlet UIImageView *resultImage;
@property (weak, nonatomic) IBOutlet UILabel *resultText;
@property NSString *jobID;
@property NSString *jobName;
@property NSString *printerName;

- (IBAction)scanButtonTapped:(id)sender;


@end
