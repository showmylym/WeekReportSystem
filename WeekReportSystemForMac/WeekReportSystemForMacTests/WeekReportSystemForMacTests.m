//
//  WeekReportSystemForMacTests.m
//  WeekReportSystemForMacTests
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "WeekReportSystemForMacTests.h"
#import <LogicForMac.h>

@interface WeekReportSystemForMacTests ()

@property LogicForMac * logicForMac;

@end

@implementation WeekReportSystemForMacTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    if (self.logicForMac == nil) {
        self.logicForMac = [LogicForMac new];
    }
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSelectAllWeekReports
{
    [self setUp];
    NSArray * array = [self.logicForMac selectAllWeekReportFromDateString:@"2013-06-03 星期一" toDateString:@"2013-06-09 星期日"];
    NSLog(@"%@", array);
    [self tearDown];
}

- (void)testSaveWeekReports {
    [self setUp];
    FSWeekReportObject * reportObject = [FSWeekReportObject new];
    reportObject.orderNum = @0;
    reportObject.createdDate = @"2013-02-30";
    reportObject.createdYear = @"2013";
    reportObject.weekNum = @200;
    reportObject.projectID = @"projectID";
    reportObject.projectName = @"projectName";
    reportObject.requirementID = @"requirementID";
    reportObject.taskContent = @"task content";
    reportObject.normalTime = @1.0;
    reportObject.overTime = @2.0;
    reportObject.carFare = @3.0;
    reportObject.mealFee = @4.0;
    reportObject.otherFee = @5.0;
    reportObject.isBusinessTrip = @1;
    reportObject.taskType = @1;
    reportObject.alert = @1;
    reportObject.startTime = @"11:00";
    reportObject.comment = @"this is comment";
    
    FSWeekReportObject * reportObject1 = [FSWeekReportObject new];
    reportObject1.orderNum = @1;
    reportObject1.createdDate = @"2013-02-30";
    reportObject1.createdYear = @"2013";
    reportObject1.weekNum = @200;
    reportObject1.projectID = @"projectID";
    reportObject1.projectName = @"projectName";
    reportObject1.requirementID = @"requirementID";
    reportObject1.taskContent = @"task content";
    reportObject1.normalTime = @2.0;
    reportObject1.overTime = @3.0;
    reportObject1.carFare = @4.0;
    reportObject1.mealFee = @5.0;
    reportObject1.otherFee = @6.0;
    reportObject1.isBusinessTrip = @1;
    reportObject1.taskType = @1;
    reportObject1.alert = @1;
    reportObject1.startTime = @"11:00";
    reportObject1.comment = @"this is comment";

    [self.logicForMac saveWeekReports:@[reportObject, reportObject1]];
    [self tearDown];
}

- (void)testSaveWeekSummary {
    [self setUp];
    FSWeekSummaryObject * summary = [FSWeekSummaryObject new];
    summary.createdYear = @"2013";
    summary.weekNum = @20;
    summary.thisSummary = @"This is the summary of this week!";
    summary.nextPlan = @"This is the plan of next week!";
    [self.logicForMac saveWeekSummary:summary];
    
    [self tearDown];

}

- (void) testRetrieveWeekSummaryID {
    [self setUp];
    FSWeekSummaryObject * summary = [FSWeekSummaryObject new];
    summary.createdYear = @"2013";
    summary.weekNum = @24;
    [self.logicForMac retrieveIDFromDatabaseByWeekSummary:summary];
    if ([summary.autoIncrementID intValue] == 0) {
        STFail(@"Unit tests are not implemented yet in LogicForMacTests");
    }
    [self tearDown];

}

- (void)testRemoveWeekObject {
    [self setUp];
    
    [self tearDown];

}

- (void)testRemoveWeekSummary {
    [self setUp];
    
    [self tearDown];

}

@end
