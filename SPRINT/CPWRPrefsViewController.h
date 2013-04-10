//
//  CPWRPrefsViewController.h
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPWRPrefsViewController : UITableViewController
- (NSString *)dataFilePath;

@property (weak, nonatomic) IBOutlet UITextField *networkIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)textFieldReturn:(id)sender;
- (IBAction)saveUserPrefAction:(id)sender;

- (void)applicationWillResignActive:(NSNotification *)notification;

@end
