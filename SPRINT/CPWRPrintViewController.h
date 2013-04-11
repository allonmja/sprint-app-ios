//
//  CPWRPrintViewController.h
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPWRPrintViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *printStatusLabel;
@property (nonatomic) NSString *jobID;
@property (nonatomic) NSString *jobName;
@property (nonatomic) NSString *printerName;

- (IBAction)printBtnClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property NSMutableArray *recentPrinters;

@property (weak, nonatomic) IBOutlet UILabel *documentLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;


@end
