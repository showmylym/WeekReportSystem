//
//  FSProjectInfoObject.h
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-7.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSProjectInfoObject : NSObject

@property NSNumber * autoIncrementID;
@property NSString * projectID;
@property NSString * projectName;
@property NSNumber * isChecked;

//these two properties are nil value in xml file
@property NSString * startDate;
@property NSString * startTime;

@end
