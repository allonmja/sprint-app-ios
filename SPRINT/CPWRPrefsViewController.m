//
//  CPWRPrefsViewController.m
//  Sprint
//
//  Created by Vincent Sam on 4/3/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRPrefsViewController.h"
#import "CPWRButtonStyles.h"

#define kFilename @"userPrefs.plist"

@interface CPWRPrefsViewController ()
{
     NSUserDefaults *userPrefs;
}

@end

@implementation CPWRPrefsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
    
    self.navigationItem.hidesBackButton = YES;
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)configureView
{
    
    CPWRButtonStyles *buttonDesigner = [[CPWRButtonStyles alloc] init];
    [buttonDesigner designButton: self.saveButton];
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    [self dataPersistence];
    
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    
//    [self.tableView addGestureRecognizer:gestureRecognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    

    [self setNetworkIDTextField:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}


- (IBAction)saveUserPrefAction:(id)sender
{
     NSLog(@"Saving preferences");
    [self saveUserPreferences];
}

- (IBAction)textFieldReturn:(id)sender
{
     [sender resignFirstResponder];   
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self saveUserPreferences];
}

- (void)dataPersistence
{
    [_networkIDTextField setText:[userPrefs objectForKey:@"userNetworkID"]];
    
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        _networkIDTextField.text = [array objectAtIndex:0];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:app];
}

- (void)saveUserPreferences
{
    
    if(_networkIDTextField.text.length > 0)
    {
        [userPrefs setObject:self.networkIDTextField.text forKey:@"userNetworkID"];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:_networkIDTextField.text];
        
        [array writeToFile:[self dataFilePath] atomically:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.navigationItem.hidesBackButton = NO;
    
}

- (void) hideKeyboard
{
    [self.networkIDTextField resignFirstResponder];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


@end
