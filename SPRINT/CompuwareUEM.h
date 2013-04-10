//
// CompuwareUEM.h
//
//
// These materials contain confidential information and
// trade secrets of Compuware Corporation. You shall
// maintain the materials as confidential and shall not
// disclose its contents to any third party except as may
// be required by law or regulation. Use, disclosure,
// or reproduction is prohibited without the prior express
// written permission of Compuware Corporation.
//
// All Compuware products listed within the materials are
// trademarks of Compuware Corporation. All other company
// or product names are trademarks of their respective owners.
//
// Copyright (c) 2011-2012 Compuware Corporation. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/*!
 * @enum CPWR_StatusCode
 * @brief Defines the possible set of return codes for CompuwareUEM methods
 * CPWR_CaptureOff - CompuwareUEM is not capturing. Events cannot be collected in this state\n
 * CPWR_CaptureOn - CompuwareUEM is capturing. Events are collected in this state\n
 * CPWR_UemOff - CompuwareUEM library is was not started\n
 * CPWR_UemOn - CompuwareUEM library is running\n
 * CPWR_Error_NotInitialized - CompuwareUEM library is not initialized. Events cannot be collected in this state\n
 * CPWR_Error_InvalidRange - the value specified is outside of permitted range (e.g. 0-2147483 for int)\n
 * CPWR_Error_InternalError - an internal error occured - use lastErrorCode and lastErrorMsg for more details\n
 * CPWR_Error_ActionNotFound - a Corresponding enterAction event was not found for the current leaveAction\n
 */
typedef enum{
    CPWR_UemOff                 = 0,
    CPWR_UemOn                  = 1,
    CPWR_CaptureOff             = 2,
    CPWR_CaptureOn              = 3,
    CPWR_Error_NotInitialized   = -1,
    CPWR_Error_InvalidRange     = -2,
    CPWR_Error_InternalError    = -3,
    CPWR_Error_ActionNotFound   = -4
} CPWR_StatusCode;

/*! @interface CompuwareUEM
 * 
 * The CompuwareUEM interface supports collection and reporting of custom events along with application state and device state information to the CompuwareUEM servers 
 */
@interface CompuwareUEM : NSObject{

}

/*!
 Initializes CompuwareUEM. This must be invoked before any Events should be captured. Multiple calls to this method will be ignored if the ADK was not shut down before.\n
 @param applicationId A user-defined name for the application
 @param serverName The URL of the web server which has a dynaTrace UEM agent placed (eg: "http://myhost.mydomain.com:8080/agentLocation/") including the transport mechanism to use (http or https) and the agent location specified in the dynaTrace UEM settings for this application
 @param allowAnyCert Allow any certificate for https communication. This will only be evaluated if the https transport mechanism is specified in the server name
 @param pathToCertificateAsDER Path to a (self-signed) certificate in DER format or nil - Adds a certificiate in DER format which is used as additional anchor to validate https communication. This is needed if allowAnyCert is NO and a self-signed certificate is used. e.g.: NSString *pathToCertificateAsDER = [[NSBundle mainBundle] pathForResource:@"easyTravelServerCert" ofType:@"der"];
 @return Returns a CPWR_StatusCode indicating success (CPWR_UemOn) or failure
 */
+ (CPWR_StatusCode)startupWithApplicationId:(NSString *)applicationId serverName:(NSString *)serverName allowAnyCert:(BOOL)allowAnyCert certificatePath:(NSString *)pathToCertificateAsDER;

/*!
 Stops CompuwareUEM monitoring. Collected Data will be flushed to the dynaTrace server.\n
 @return Returns a CPWR_StatusCode indicating success (CPWR_UemOff) or failure
 */
+ (CPWR_StatusCode)shutdown;

/*!
 Starts an action, which will result in a mobile action PurePath in dynaTrace. Call this method at the beginning of the code that you wish to time. The action end must be set via a call to leaveAction:\n
 @param actionName Name of action
 @return Returns a CPWR_StatusCode indicating success (CPWR_CaptureOn) or failure
 The lastErrorMsg can be invoked to fetch details on the error condition\n
 */
+ (CPWR_StatusCode)enterAction:(NSString *)actionName;

/*!
 Ends a previously started action. All reported events, values or tagged web requests between start and end of an action will be part of the action, i.e. nested in the mobile action PurePath. Call to this method at the end of the code that you wish to time. The number of milliseconds since the page load began is stored as the end time for the action with the specified name. enterAction: must be called with the same actionName prior to this method.\n
 @param actionName Name of action
 @return Returns a CPWR_StatusCode indicating success (CPWR_CaptureOn) or failure (CPWR_Error_ActionNotFound indicates that the corresponding enterAction: is missing)
 The lastErrorMsg can be invoked to fetch details on the error condition\n
 */
+ (CPWR_StatusCode)leaveAction:(NSString *)actionName;

/*!
 Sends an event to dynaTrace, which results in either a node of a mobile action PurePath, if an action is currently active or in a separate PurePath with only an event node\n
 @param eventName Name of event
 @return Returns a CPWR_StatusCode indicating success or failure
 The lastErrorMsg can be invoked to fetch details on the error condition\n
 */
+ (CPWR_StatusCode)reportEvent:(NSString *)eventName;

/*!
 Sends a key/value pair to dynaTrace, which results in either a node of a mobile action PurePath, if an action is currently active or in a separate PurePath with only an event node. The value can be processed by a measure and thus be charted.\n
 @param valueName Name of value
 @param value an integer value associated with the value name
 @return Returns a CPWR_StatusCode indicating success (CPWR_CaptureOn) or failure, CPWR_Error_InvalidRange will be returned if the value specified is outside of permitted range (e.g. 0-2147483 for int)
 The lastErrorMsg can be invoked to fetch details on the error condition\n
 */
+ (CPWR_StatusCode)reportValue:(NSString *)valueName value:(NSInteger)value;

/*!
 Returns if application is currently capturing UEM data or not\n
 @return Returns a CPWR_StatusCode indicating on (CPWR_CaptureOn) or off (CPWR_CaptureOff - e.g. if communication with dynaTrace server failed, CPWR_UemOff)
 */
+ (CPWR_StatusCode)uemCaptureStatus;

/*!
 Returns if the CompuwareUEM library was started or not\n
 @return Returns a CPWR_StatusCode indicating if CompuwareUEM is running (CPWR_UemOn) or not (CPWR_UemOff)
 */
+ (CPWR_StatusCode)uemStatus;

/*!
 Returns the CLLocation object specifying the previously configured GPS coordinates. The CompuwareUEM library does not automatically collect any location information. The location information may be specified via setGpsLocation:\n
 @return Returns the GPS coordinates as a CLLocation object. Will be nil if invoked before a setGpsLocation call
 */
+ (CLLocation *)gpsLocation;

/*!
 May be used to record the current GPS location of the user. The CompuwareUEM library does not automatically collect any location information.\n
 Note that in compliance with privacy laws, the application is responsible for obtaining relevant permissions from the end-user before collecting the GPS coordinates (already handled by iOS on first time using the CLLocationManager API).\n
 @param gpsLocation CLLocation object with GPS coordinates aquired by customer application
 @return Returns a CPWR_StatusCode indicating current uem capture status (if the ADK is not capturing no GPS location is set)
 */
+ (CPWR_StatusCode)setGpsLocation:(CLLocation *)gpsLocation;

/*!
 Can be invoked to obtain the error code associated with the most recent CPWR_Error_InternalError condition\n
 @return Returns the error code associated with the internal error condition. 0 if there is no internal error\n 
 */
+ (CPWR_StatusCode)lastErrorCode;

/*!
 Can be invoked to obtain the error message associated with most recent CPWR_Error_InternalError condition\n
 @return Returns the error message associated with the internal error condition. Nil if there is no internal error\n 
 */
+ (NSString *)lastErrorMsg;

/*!
 Can be invoked to obtain the CompuwareUEM Server name\n
 @return Returns the CompuwareUEM Server name (e.g. WebServer with dynaTrace Agent) with format protocol://host:port/agentPath\n 
 */
+ (NSString *)serverName;

/*!
 Send all collected events immediately. To reduce network traffic/usage the collected events are usually sent in packages where the oldest event has an age of up to 9 minutes. Using this method you can force sending of all collected events regardless of their age (e.g. if the App currently has an active data connection via Wifi/mobile to avoid establising a connection just for sending collected data).\n
 */
+ (CPWR_StatusCode)flushEvents;

@end
