//
//  FSWeekReportObject.m
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-7.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSWeekReportObject.h"

@implementation FSWeekReportObject

- (id)init {
    self = [super init];
    if (self) {
        _autoIncrementID    = nil;
        _orderNum           = @0;
        _createdDate        = @"";
        _createdYear        = @"";
        _weekNum            = @0;
        _projectID          = @"";
        _projectName        = @"";
        _requirementID      = @"";
        _taskContent        = @"";
        _normalTime         = @0.0;
        _overTime           = @0.0;
        _carFare            = @0.0;
        _mealFee            = @0;
        _otherFee           = @0.0;
        _isBusinessTrip     = @0;
        _taskType           = @0;
        _alert              = @0;
        _startTime          = @"";
        _comment            = @"";
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FSWeekReportObject * copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.autoIncrementID    = [_autoIncrementID copy];
        copy.orderNum           = [_orderNum copy];
        copy.createdDate        = [_createdDate copy];
        copy.createdYear        = [_createdYear copy];
        copy.weekNum            = [_weekNum copy];
        copy.projectID          = [_projectID copy];
        copy.projectName        = [_projectName copy];
        copy.requirementID      = [_requirementID copy];
        copy.taskContent        = [_taskContent copy];
        copy.normalTime         = [_normalTime copy];
        copy.overTime           = [_overTime copy];
        copy.carFare            = [_carFare copy];
        copy.mealFee            = [_mealFee copy];
        copy.otherFee           = [_otherFee copy];
        copy.isBusinessTrip     = [_isBusinessTrip copy];
        copy.taskType           = [_taskType copy];
        copy.alert              = [_alert copy];
        copy.startTime          = [_startTime copy];
        copy.comment            = [_comment copy];
        
        copy.firstDateStringThisWeek    = _firstDateStringThisWeek;
        copy.lastDateStringThisWeek     = _lastDateStringThisWeek;
        copy.weekSummaryObject          = _weekSummaryObject;
    }
    return copy;
}

- (NSString *)description {
    NSString * string = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\nisBiz:%@\n%@\nalert:%@\n%@\n%@\n%@\n%@\n%@\n", _autoIncrementID, _orderNum, _createdDate, _createdYear, _weekNum, _projectID, _projectName, _requirementID, _taskContent, _normalTime, _overTime, _carFare, _mealFee, _otherFee, _isBusinessTrip, _taskType, _alert, _startTime, _comment, _firstDateStringThisWeek, _lastDateStringThisWeek, _weekSummaryObject];
    
    return string;
}

@end
