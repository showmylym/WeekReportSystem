//
//  NSAlert+Error.m
//  WeekReportSystemLogic
//
//  Created by Leiyiming on 13-6-9.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "NSAlert+Error.h"

@implementation NSAlert (Error)

+ (NSInteger)showErrorMessage:(NSString *)errorMessage {
    NSAlert * alert = [NSAlert alertWithMessageText:errorMessage defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@""];
    [[alert window] setTitle:@"提示"];
    return [alert runModal];
}

@end
