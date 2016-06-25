//
//  CommonFunctions.m
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-9.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "CommonFunctions.h"

BOOL isEmptyString(NSString * str) {
    BOOL isEmp = YES;
    if ([str length] > 0) {
        isEmp = NO;
    }
    return isEmp;
}