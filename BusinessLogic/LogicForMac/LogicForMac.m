//
//  LogicForMac.m
//  LogicForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//
#import "LogicForMac.h"

@interface LogicForMac ()

@property FSMainLogic * mainLogic;

@end


@implementation LogicForMac


- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"will copy sqlite file");
        [self copySqliteFile];
        NSLog(@"did copy sqlite file");
        self.mainLogic = [FSMainLogic new];
    }
    return self;
}


- (NSArray *)selectAllWeekReportFromDateString:(NSString *)fromDateString toDateString:(NSString *)toDateString {
    assert(self.mainLogic);
    return [self.mainLogic selectAllWeekReportFromDateString:fromDateString toDateString:toDateString];
}

- (FSWeekSummaryObject *)selectOneWeekSummaryByCreatedYear:(NSString *) createdYear weekNum:(NSNumber *)weekNum {
    assert(self.mainLogic);
    return [self.mainLogic selectOneWeekSummaryByCreatedYear:createdYear weekNum:weekNum];
}

- (BOOL)retrieveIDFromDatabaseByWeekSummary:(FSWeekSummaryObject *)weekSummary {
    assert(self.mainLogic);
    return [self.mainLogic retrieveIDFromDatabaseByWeekSummary:weekSummary];
}

- (BOOL)retrieveIDFromDatabaseByWeekReports:(NSArray *)weekReportsArray {
    assert(self.mainLogic);
    return [self.mainLogic retrieveIDFromDatabaseByWeekReports:weekReportsArray];
}

- (BOOL)saveWeekReports:(NSArray *)weekReports {
    assert(self.mainLogic);

    return [self.mainLogic saveWeekReports:weekReports];
}

- (BOOL)saveWeekSummary:(FSWeekSummaryObject *)weekSummary {
    assert(self.mainLogic);
    return [self.mainLogic saveWeekSummary:weekSummary];
}

- (NSURL *)outputWeekReports:(NSArray *)weekReportsArray {
    assert(self.mainLogic);
    return [self.mainLogic outputWeekReports:weekReportsArray];
}

- (BOOL)removeWeekReport:(FSWeekReportObject *)weekReportObj fromReportsMutableArray:(NSMutableArray *)reports {
    assert(self.mainLogic);
    return [self.mainLogic removeWeekReport:weekReportObj fromReportsMutableArray:reports];
}

- (NSArray *)projectInfosParsedByXMLFile:(NSURL *)fileURL {
    assert(self.mainLogic);
    return [self.mainLogic projectInfosParsedByXMLFile:fileURL];
}

- (void) saveInputProjectInfos:(NSArray *)projectInfos {
    assert(self.mainLogic);
    [self.mainLogic saveInputProjectInfos:projectInfos];
}

- (BOOL) saveProjectInfo:(FSProjectInfoObject *)projectInfoObj {
    assert(self.mainLogic);
    return [self.mainLogic saveProjectInfo:projectInfoObj];
}

- (BOOL)retrieveIDFromDatabaseByProjectsInfo:(NSArray *)projectsInfo {
    assert(self.mainLogic);
    return [self.mainLogic retrieveIDFromDatabaseByProjectsInfo:projectsInfo];
}

- (NSArray *) selectProjectsInfoIsChecked {
    assert(self.mainLogic);
    NSArray * results = [self.mainLogic selectProjectsInfoIsChecked];
    NSMutableArray * resultsForMac = [NSMutableArray arrayWithCapacity:10];
    [resultsForMac addObject:[NSNull null]];
    if ([results count] > 0) {
        [resultsForMac addObjectsFromArray:results];
    }
    return resultsForMac;
}

- (NSArray *) selectAllProjectsInfos {
    assert(self.mainLogic);
    return [self.mainLogic selectAllProjectsInfos];
}

- (BOOL) clearAllProjectsInfoInDatabase {
    assert(self.mainLogic);
    return [self.mainLogic clearAllProjectsInfoInDatabase];
}


#pragma mark - private methods

- (void) copySqliteFile {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * sourcePath = [[NSBundle mainBundle] pathForResource:@"WeekReport" ofType:@"sqlite" inDirectory:nil];
    NSString * targetPath = [FSMainLogic SqlitePath];
    NSString * errorText = nil;
    
    BOOL isDirectory = NO;
    BOOL fileHasExists = [fileManager fileExistsAtPath:targetPath
                                           isDirectory:&isDirectory];
    NSError * error = nil;

    if (!fileHasExists) {
        NSLog(@"createDirectoryAtPath:%@", targetPath);
        BOOL success = [fileManager createDirectoryAtPath:[targetPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            errorText = @"\nData目录创建失败导致无法拷贝数据库，可能因为访问权限不够！程序即将退出！";
        } else {
            success = [fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error];
            if (!success) {
                errorText = @"数据库文件拷贝失败！程序即将退出";
            }
        }
        
        if (!success) {
            if ([NSAlert showErrorMessage:errorText] == 1) {
                exit(1);
            }
        } else {
            //拷贝成功的判断（FileManager的copy方法，是同步方法，但不加此判断块，会造成程序刚启动时能看到界面但无法点击）
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
                    if ([NSAlert showErrorMessage:@"数据库拷贝超时，程序即将关闭！"] == 1) {
                        exit(1);
                    }
                }
                count ++;
            } while (1);

        }
        
    }
    
}

- (NSInteger)weekNumOfDate:(NSDate *)selectedDate {
    assert(self.mainLogic);
    return [self.mainLogic weekNumOfDate:selectedDate];
}

- (NSArray *)firstAndLastDayStringByDate:(NSDate *)selectedDate {
    assert(self.mainLogic);
    return [self.mainLogic firstAndLastDayStringByDate:selectedDate];
}

- (NSArray *)firstAndLastDayStringByDate:(NSDate *)selectedDate withFormatter:(NSDateFormatter *)formatter {
    assert(self.mainLogic);
    return [self.mainLogic firstAndLastDayStringByDate:selectedDate withFormatter:formatter];
}

- (BOOL)sendToServer:(const char *)ipAdress port:(NSUInteger)port withFile:(NSURL *)fileURL {
    assert(self.mainLogic);
    return [self.mainLogic sendToServer:ipAdress port:port withFile:fileURL];
}

@end
