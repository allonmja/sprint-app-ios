//
//  CPWRSprintDBHelper.m
//  SPRINT
//
//  Created by Vincent Sam on 4/8/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRSprintDBHelper.h"

@implementation CPWRSprintDBHelper


- (void)setupSprintDB
{
    /* create SPRINT Database */
    [self createDB];
}

- (void)createDB
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self setDatabasePath: [[NSString alloc] initWithString:[docPath stringByAppendingPathComponent:@"sprint.db"]]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if(![filemgr fileExistsAtPath:[self databasePath]])
    {
        if(sqlite3_open([[self databasePath] UTF8String], &_sprintDB) == SQLITE_OK)
        {
            char *errMsg;
            NSString *sql = @"CREATE TABLE IF NOT EXISTS RecentPrinters"
            @"(ID INTEGER PRIMARY KEY AUTOINCREMENT, "
            @"name TEXT, location TEXT, color TEXT)";
            
            if(sqlite3_exec(_sprintDB, [sql UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_sprintDB);
        }else{
            NSLog(@"Failed to open/create database");
        }
    }
    
}


- (void)recordRecentPrinter:(NSString *)printerName
{
    
}

- (void)deleteRecentPrinter:(NSString *)printerName
{
    
}

- (NSMutableArray *)getRecentPrinters
{
    NSMutableArray *printers = [[NSMutableArray alloc] init];
    
    
    return printers;
}

@end
