//
//  CPWRMainTabsController.h
//  Sprint
//
//  Created by Vincent Sam on 4/2/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPWRPrefsViewController.h"

@interface CPWRMainTabsController : UITabBarController

- (IBAction)scanBtnClicked:(id)sender;

- (NSString *)dataFilePath;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *preferencesButton;

@end
