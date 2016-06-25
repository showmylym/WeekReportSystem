//
//  FSProjectInfoObject.m
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-7.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSProjectInfoObject.h"

@implementation FSProjectInfoObject

- (id)init {
    self = [super init];
    if (self) {
        _autoIncrementID = nil;
        _projectID = @"";
        _projectName = @"";
        _isChecked = @0;
        _startDate = @"";
        _startTime = @"";
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n{projectID:%@,\nprojectName:%@,\nisChecked:%@}", self.projectID, self.projectName, self.isChecked];
}
@end
