//
//  FSWeekSummaryObject.m
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-7.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSWeekSummaryObject.h"

@implementation FSWeekSummaryObject

- (id)init {
    self = [super init];
    if (self) {
        _createdYear = @"";
        _weekNum = @0;
        _thisSummary = @"";
        _nextPlan = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FSWeekSummaryObject * copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.autoIncrementID = [_autoIncrementID copy];
        copy.createdYear = [_createdYear copy];
        copy.weekNum = [_weekNum copy];
        copy.thisSummary = [_thisSummary copy];
        copy.nextPlan = [_nextPlan copy];
    }
    return copy;
}

- (NSString *)description {
    NSString * string = [NSString stringWithFormat:@"%@, %@, %@, %@", _createdYear, _weekNum, _thisSummary, _nextPlan];
    return string;
}

@end
