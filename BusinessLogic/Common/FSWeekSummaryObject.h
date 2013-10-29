//
//  FSWeekSummaryObject.h
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-7.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSWeekSummaryObject : NSObject
<NSCopying>

@property (strong) NSNumber * autoIncrementID;
//Accoding to the definition of class FSWeekReportObject, we can use two property "createdYear" and "weekNum" to releated to its instance
@property (strong) NSString * createdYear;
@property (strong) NSNumber * weekNum;
@property (strong) NSString * thisSummary;
@property (strong) NSString * nextPlan;

@end
