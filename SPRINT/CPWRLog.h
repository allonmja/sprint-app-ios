//
//  CPWRLog.h
//  CompuwareUEM
//
//  Created by Patrick Haruksteiner on 2012-02-03.
//  Copyright (c) 2012 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 convenience macros for logging
 */
#define log(level, message, ...) [CPWRLog logWithLevel:level file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logSevere(message, ...) [CPWRLog logWithLevel:SEVERE file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logWarning(message, ...) [CPWRLog logWithLevel:WARNING file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logInfo(message, ...) [CPWRLog logWithLevel:INFO file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logConfig(message, ...) [CPWRLog logWithLevel:CONFIG file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logFine(message, ...) [CPWRLog logWithLevel:FINE file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logFiner(message, ...) [CPWRLog logWithLevel:FINER file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];
#define logFinest(message, ...) [CPWRLog logWithLevel:FINEST file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ format:message, ##__VA_ARGS__];

/*!
 * @enum cpwrLogLevel
 * @brief Defines the possible set of log levels
 */
typedef enum{
    ALL = NSIntegerMin,
    FINEST = 300,
    FINER = 400,
    FINE = 500,
    CONFIG = 700,
    INFO = 800,
    WARNING = 900,
    SEVERE = 1000,
    OFF = NSIntegerMax
}cpwrLogLevel;

@interface CPWRLog : NSObject

/*!
 Set the global loglevel\n
 @param logLevel The loglevel
 */
+ (void)setLogLevel:(cpwrLogLevel)logLevel;

/*!
 Get the currently set global loglevel\n
 @return returns the global logLevel
 */
+ (cpwrLogLevel)logLevel;

/*!
 Converts a logLevel to a human readable format\n
 @param The logLevel to convert
 @return The human readable form of the logLevel
 */
+ (NSString *)logLevelName:(cpwrLogLevel)logLevel;

/*!
 Indicates if a message with a cretain loglevel will be logged\n
 This can be used to wrap tha actual log message with if([CPWRLog willLogForLevel:<level>]){log(...)} to avoid memory allocation for the log message and its arguments if they will not be logged\n
 @param The logLevel
 @return YES if the message will be written to the log for the selected logLevel, NO if it will not be logged
 */
+ (BOOL)willLogForLevel:(cpwrLogLevel)logLevel;

/*!
 Creates a log if the loglevel is set finer or equal to the global loglevel\n
 Use the convenience macro log(level, message, ...) which inserts file and line number for you.\n
 There are also convenienceMacros for all log levels like logSever(message, ...), logWarning(Message, ...), ...
 @param level The log level	
 @param file The file name
 @param line The line number
 @param format The format string and its variable arguments
 \n
 */
+ (void)logWithLevel:(cpwrLogLevel)level file:(NSString*)file line:(NSInteger)line format:(NSString *)message, ...;

@end
