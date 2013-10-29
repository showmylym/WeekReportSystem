//
//  FSMainLogic.h
//  WeekReportSystemLogic
//
//  Created by forms_chenrui on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FSWeekReportObject.h"
#import "FSWeekSummaryObject.h"
#import "FSRequirementObject.h"
#import "FSProjectInfoObject.h"

#import "CommonFunctions.h"
#import "ErrorCode.h"
#if TARGET_OS_IPHONE
#define DocumentDirectory \
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define CachesDirectory \
[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#else
#import "NSAlert+Error.h"
#define AppInDirectory \
[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]

#endif


#define kErrorMessage                          @"errorMessage"
#define kID                         @"ProfileID"
#define kName                       @"ProfileName"
#define kServerAddress              @"ServerAddress"

extern NSString * const DefaultServerAddress;

extern NSString * const ErrorOccuredNotification;
extern NSString * const NeedSaveNotification;


extern NSString * const XMLParseErrorDomain;
extern NSString * const DataBaseErrorDomain;
extern NSString * const OutPutReportErrorDomain;
extern NSString * const SocketErrorDomain;


extern NSString * const LocalTimeZone;
extern NSString * const LocaleIdentifier;


@interface FSMainLogic : NSObject

+ (NSString *) SqlitePath;

/*
 * returned array : array of FSWeekReportObject objects
 * FromDate and toDate String Format is: 2013-05-31 星期五
 */
- (NSArray *)selectAllWeekReportFromDateString:(NSString *)fromDateString
                                  toDateString:(NSString *)toDateString;

- (FSWeekSummaryObject *)selectOneWeekSummaryByCreatedYear:(NSString *) createdYear weekNum:(NSNumber *)weekNum;

- (BOOL)retrieveIDFromDatabaseByWeekSummary:(FSWeekSummaryObject *)weekSummary;

- (BOOL)retrieveIDFromDatabaseByWeekReports:(NSArray *)weekReportsArray;

/*
 * weekReports is a number of objects which are the instances of FSWeekReportObject
 */
- (BOOL)saveWeekReports:(NSArray *)weekReports;

- (BOOL)saveWeekSummary:(FSWeekSummaryObject *)weekSummary;

- (NSURL *)outputWeekReports:(NSArray *)weekReportsArray;

/*
 *
 */

- (BOOL)removeWeekReport:(FSWeekReportObject *)weekReportObj fromReportsMutableArray:(NSMutableArray *)reports;
//- (BOOL)removeWeekSummary:(FSWeekSummaryObject *)weekSummaryObj;

/*
 * project info input
 */
- (NSArray *)projectInfosParsedByXMLFile:(NSURL *)fileURL;

- (void) saveInputProjectInfos:(NSArray *)projectInfos;

- (BOOL) saveProjectInfo:(FSProjectInfoObject *)projectInfoObj;

- (BOOL) retrieveIDFromDatabaseByProjectsInfo:(NSArray *)projectsInfo;

- (NSArray *) selectProjectsInfoIsChecked;

- (NSArray *) selectAllProjectsInfos;

- (BOOL) clearAllProjectsInfoInDatabase;

/*
 * week and date operation
 */
- (NSInteger) weekNumOfDate:(NSDate *) selectedDate;
- (NSArray *) firstAndLastDayStringByDate:(NSDate *)selectedDate;
- (NSArray *) firstAndLastDayStringByDate:(NSDate *)selectedDate withFormatter:(NSDateFormatter *)formatter;


/* send report to server
 */

- (BOOL)sendToServer:(const char *)ipAdress port:(NSUInteger)port withFile:(NSURL *)fileURL;

@end
