//
//  LogicForiOS.m
//  LogicForiOS
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "LogicForiOS.h"


@implementation LogicForiOS

- (id)init {
    self = [super init];
    if (self) {
        [self copySqliteFile];
        [self copyProjectFile];
    }
    return self;
}

- (void) copySqliteFile {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * sourcePath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"sqlite" inDirectory:nil];
    NSString * targetPath = [FSMainLogic SqlitePath];
    
    BOOL isDirectory = NO;
    BOOL fileHasExists = [fileManager fileExistsAtPath:targetPath
                                           isDirectory:&isDirectory];
    NSError * error = nil;
    
    if (!fileHasExists) {
        NSLog(@"createDirectoryAtPath:%@", targetPath);
        BOOL success = [fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error];
        assert(success);
        if (success && error != nil) {
            NSLog(@"%@", error);
            assert(NO);
        }
    }
    NSInteger count = 0;
    NSData * sourceFileData = [NSData dataWithContentsOfFile:sourcePath];
    NSData * targetFileData;
    do {
        targetFileData = [NSData dataWithContentsOfFile:targetPath];
        if ([sourceFileData length] == [targetFileData length]) {
            break;
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:1]];
        if (count > 20) {
            exit(1);
            break;
        }
        count ++;
    } while (1);
    
}

- (void) copyProjectFile {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * sourcePath = [[NSBundle mainBundle] pathForResource:@"project" ofType:@"xml" inDirectory:nil];
    NSString * targetPath = [CachesDirectory stringByAppendingPathComponent:@"project.xml"];
    
    BOOL isDirectory = NO;
    BOOL fileHasExists = [fileManager fileExistsAtPath:targetPath
                                           isDirectory:&isDirectory];
    NSError * error = nil;
    
    if (!fileHasExists) {
        NSLog(@"createDirectoryAtPath:%@", targetPath);
        BOOL success = [fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error];
        assert(success);
        if (success && error != nil) {
            NSLog(@"%@", error);
            assert(NO);
        }
    }
    NSInteger count = 0;
    NSData * sourceFileData = [NSData dataWithContentsOfFile:sourcePath];
    NSData * targetFileData;
    do {
        targetFileData = [NSData dataWithContentsOfFile:targetPath];
        if ([sourceFileData length] == [targetFileData length]) {
            break;
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:1]];
        if (count > 20) {
            exit(1);
            break;
        }
        count ++;
    } while (1);
    
}

@end
