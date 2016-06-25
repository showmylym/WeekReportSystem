//
//  LogicForMac.h
//  LogicForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMainLogic.h"
#import "NSAlert+Error.h"

@interface LogicForMac : NSObject

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

