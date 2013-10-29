//
//  NSAlert+Error.h
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-9.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAlert (Error)

+ (NSInteger)showErrorMessage:(NSString *)errorMessage;

@end
