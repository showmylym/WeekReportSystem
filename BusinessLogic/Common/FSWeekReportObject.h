//
//  FSWeekReportObject.h
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-7.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSWeekSummaryObject.h"

@interface FSWeekReportObject : NSObject
<NSCopying>

//property from databse
@property NSNumber * autoIncrementID;
@property NSNumber * orderNum;
//Accoding to the definition of class FSWeekSummaryObject, we can use two property "createdYear" and "weekNum" to releated to its instance
@property NSString * createdDate;
@property NSString * createdYear;
@property NSNumber * weekNum;
@property NSString * projectID;
@property NSString * projectName;
@property NSString * requirementID;
@property NSString * taskContent;
@property NSNumber * normalTime;
@property NSNumber * overTime;
@property NSNumber * carFare;
@property NSNumber * mealFee;
@property NSNumber * otherFee;
@property NSNumber * isBusinessTrip;
@property NSNumber * taskType;
@property NSNumber * alert;
@property NSString * startTime;
@property NSString * comment;

//date for using in program
@property NSString * firstDateStringThisWeek;
@property NSString * lastDateStringThisWeek;
@property FSWeekSummaryObject * weekSummaryObject;

@end
