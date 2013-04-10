//
//  CPWRSprintDBHelper.h
//  SPRINT
//
//  Created by Vincent Sam on 4/8/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPWRSprintDBHelper : NSObject

@property (nonatomic) sqlite3 *sprintDB;
@property (copy, nonatomic) NSString *databasePath;

- (void)setupSprintDB;
- (void)recordRecentPrinter:(NSString *)printerName;
- (void)deleteRecentPrinter:(NSString *)printerName;
- (NSMutableArray *)getRecentPrinters;

@end
