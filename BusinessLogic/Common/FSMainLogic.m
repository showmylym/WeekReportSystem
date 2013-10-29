//
//  FSMainLogic.m
//  WeekReportSystemLogic
//
//  Created by forms_chenrui on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSMainLogic.h"
#import "GDataXMLNode.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface FSMainLogic () {
    sqlite3 * _db;
}

@property NSCalendar * gregorianCalendar;
@property NSDateFormatter * dateFormatter;
@end


@implementation FSMainLogic

+ (NSString *) SqlitePath {
#if TARGET_OS_IPHONE
    NSString * sqlitePath = [CachesDirectory stringByAppendingPathComponent:@"WeekReport.sqlite"];
#else
    NSString * sqlitePath = [AppInDirectory stringByAppendingPathComponent:@"/Data/WeekReport.sqlite"];
    
#endif
    return sqlitePath;
}

- (id)init {
    self = [super init];
    if (self) {
        _db = [self initDataBase];
        self.dateFormatter = [NSDateFormatter new];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd cccc"];
        self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [self.gregorianCalendar setMinimumDaysInFirstWeek:1];
        [self.gregorianCalendar setFirstWeekday:2];
        
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_db);
    _db = NULL;
}

- (void) postErrorNotificationOfMessage:(NSString *)errorText
                            errorDomain:(NSString *)errorDomain
                              errorCode:(NSInteger)errorCode {
    NSDictionary * userInfo = @{kErrorMessage:errorText};
    NSError * error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:ErrorOccuredNotification
                                                        object:self
                                                      userInfo:@{@"error":error}];
    
}

- (const char *)makeResultLegal:(const unsigned char *)result {
    if (result == NULL) {
        return "";
    } else {
        return (const char *)result;
    }
}

#pragma - sqlite initialization
// Returns a reference to the database, creating and opening if necessary.
- (sqlite3 *)initDataBase {
    NSCAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    sqlite3 * database = NULL;
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([[[self class] SqlitePath] UTF8String], &database) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        database = NULL;
        NSCAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // crash app
        NSString * errorText = @"\n数据库初始化失败，程序即将退出！";
        
#if TARGET_OS_IPHONE
        
#else
        [NSAlert showErrorMessage:errorText];
        exit(1);
        
#endif
    }
    return database;
}

- (NSArray *)selectAllWeekReportFromDateString:(NSString *)fromDateString toDateString:(NSString *)toDateString {
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:20];
    sqlite3_stmt * pstmt = NULL;
    
    const char * sqlWeekReport = "select * from WeekReport where createdDate >= ? and createdDate <= ? order by createdDate, orderNum";
    if (sqlite3_prepare_v2(_db, sqlWeekReport, -1, &pstmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
    }
    // Bind the parser type to the statement.
    
    if (sqlite3_bind_text(pstmt, 1, [fromDateString UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    if (sqlite3_bind_text(pstmt, 2, [toDateString UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    
    int success = 0;
    while ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
        @autoreleasepool {
            FSWeekReportObject * weekReportObj = [FSWeekReportObject new];
            weekReportObj.autoIncrementID      = [NSNumber numberWithInt: sqlite3_column_int(pstmt, 0)];
            weekReportObj.orderNum             = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 1)];
            weekReportObj.createdDate          = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 2)]];
            weekReportObj.createdYear          = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 3)]];
            weekReportObj.projectID            = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 4)]];
            weekReportObj.projectName          = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 5)]];
            weekReportObj.requirementID        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 6)]];
            weekReportObj.taskContent          = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 7)]];
            weekReportObj.normalTime           = [NSNumber numberWithDouble:sqlite3_column_double(pstmt, 8)];
            weekReportObj.overTime             = [NSNumber numberWithDouble:sqlite3_column_double(pstmt, 9)];
            weekReportObj.carFare              = [NSNumber numberWithDouble:sqlite3_column_double(pstmt, 10)];
            weekReportObj.mealFee              = [NSNumber numberWithDouble:sqlite3_column_double(pstmt, 11)];
            weekReportObj.otherFee             = [NSNumber numberWithDouble:sqlite3_column_double(pstmt, 12)];
            weekReportObj.isBusinessTrip       = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 13)];
            weekReportObj.taskType             = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 14)];
            weekReportObj.alert                = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 15)];
            weekReportObj.startTime            = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 16)]];
            weekReportObj.comment              = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 17)]];
            weekReportObj.weekNum              = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 18)];
            
            [results addObject:weekReportObj];
        }
    }
    if (success != SQLITE_DONE) {
        NSString * errorText = [NSString stringWithFormat:@"\n查询周报时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
    }
    
    // Destroy the query for the next use.
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    
    if ([results count] > 0) {
        NSString * createdYear = [(FSWeekReportObject *)[results objectAtIndex:0] createdYear];
        NSNumber * weekNum = [(FSWeekReportObject *)[results objectAtIndex:0] weekNum];
        const char * sqlWeekSummary = "select * from WeekSummary where createdYear = ? and weekNum = ?";
        if (sqlite3_prepare_v2(_db, sqlWeekSummary, -1, &pstmt, NULL) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_bind_text(pstmt, 1, [createdYear UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_bind_int(pstmt, 2, [weekNum intValue]) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        
        success = 0;
        if ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
            NSNumber * autoIncrementID = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
            NSString * thisSummary = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 3)]];
            NSString * nextPlan = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 4)]];
            FSWeekSummaryObject * weekSummaryObject = [FSWeekSummaryObject new];
            weekSummaryObject.autoIncrementID = autoIncrementID;
            weekSummaryObject.thisSummary = thisSummary;
            weekSummaryObject.nextPlan = nextPlan;
            weekSummaryObject.weekNum = weekNum;
            weekSummaryObject.createdYear = createdYear;
            for (FSWeekReportObject * obj in results) {
                obj.weekSummaryObject = weekSummaryObject;
            }
        }
        if (success != SQLITE_ROW && success != SQLITE_DONE) {
            NSString * errorText = [NSString stringWithFormat:@"\n查询周报总结时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
            
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
            NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_step(pstmt) == SQLITE_ROW) {
            NSString * errorText = [NSString stringWithFormat:@"\n获取周报总结ID时重复的被自动忽略！"];
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
            
        }
        
    }
    // Destroy the query for the next use.
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    
    return results;
}

- (FSWeekSummaryObject *)selectOneWeekSummaryByCreatedYear:(NSString *) createdYear weekNum:(NSNumber *)weekNum {
    FSWeekSummaryObject * weekSummaryObj = nil;
    sqlite3_stmt * pstmt = NULL;
    const char * sqlSummary = "select * from WeekSummary where createdYear = ? and weekNum = ?";
    if (sqlite3_prepare_v2(_db, sqlSummary, -1, &pstmt, NULL) != SQLITE_OK) {
        NSAssert(0, @"Error:preparing statement in selectOneWeekSummary, '%s'", sqlite3_errmsg(_db));
    }
    
    if (sqlite3_bind_text(pstmt, 1, [createdYear UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    
    if (sqlite3_bind_int(pstmt, 2, [weekNum intValue]) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    
    int success = 0;
    if ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
        weekSummaryObj = [FSWeekSummaryObject new];
        weekSummaryObj.autoIncrementID  = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
        weekSummaryObj.createdYear      = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 1)]];
        weekSummaryObj.weekNum          = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 2)];
        weekSummaryObj.thisSummary      = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 3)]];
        weekSummaryObj.nextPlan         = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 4)]];
    }
    if (success != SQLITE_ROW && success != SQLITE_DONE) {
        NSString * errorText = [NSString stringWithFormat:@"\n获取周报总结时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
        
    }
    
    if (sqlite3_step(pstmt) == SQLITE_ROW) {
        NSString * errorText = [NSString stringWithFormat:@"\n获取周报总结时重复的被自动忽略！"];
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
    }
    
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    
    return weekSummaryObj;
    
}

- (BOOL)retrieveIDFromDatabaseByWeekSummary:(FSWeekSummaryObject *)weekSummary {
    BOOL isSusscess = NO;
    if ([weekSummary.weekNum intValue] != 0 && !isEmptyString(weekSummary.createdYear)) {
        int weekNum = [weekSummary.weekNum intValue];
        NSString * createdYear = weekSummary.createdYear;
        char * sql = "select * from WeekSummary where createdYear = ? and weekNum = ?";
        sqlite3_stmt * pstmt = NULL;
        if (sqlite3_prepare_v2(_db, sql, -1, &pstmt, NULL) != SQLITE_OK) {
            NSAssert(0, @"Error:preparing statement in retrieveIDFromDatabaseByWeekSummary, '%s'", sqlite3_errmsg(_db));
        }
        
        if (sqlite3_bind_text(pstmt, 1, [createdYear UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        
        if (sqlite3_bind_int(pstmt, 2, weekNum) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        int success = 0;
        if ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
            weekSummary.autoIncrementID = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
            isSusscess = YES;
        }
        if (success != SQLITE_ROW && success != SQLITE_DONE) {
            NSString * errorText = [NSString stringWithFormat:@"\n获取周报总结ID时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
            NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
            
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
        }
        
        if (sqlite3_step(pstmt) == SQLITE_ROW) {
            NSString * errorText = [NSString stringWithFormat:@"\n获取周报总结ID时重复的被自动忽略！"];
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
        }
        
        sqlite3_finalize(pstmt);
        pstmt = NULL;
    } else {
        NSString * errorText = @"\n获取周报总结ID时发生错误！";
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        NSLog(@"can't get weekSummary ID by weekNum and createdYear!");
    }
    return isSusscess;
    
}

- (BOOL)retrieveIDFromDatabaseByWeekReports:(NSArray *)weekReportsArray {
    BOOL isSusscess = NO;
    sqlite3_stmt * pstmt = NULL;
    
    for (FSWeekReportObject * weekReportObj in weekReportsArray) {
        if (!isEmptyString(weekReportObj.createdDate)) {
            int orderNum = [weekReportObj.orderNum intValue];
            NSString * createdDateString = weekReportObj.createdDate;
            
            char * sql = "select * from WeekReport where createdDate = ? and orderNum = ?";
            if (sqlite3_prepare_v2(_db, sql, -1, &pstmt, NULL) != SQLITE_OK) {
                NSAssert(0, @"Error:preparing statement in retrieveIDFromDatabaseByWeekSummary, '%s'", sqlite3_errmsg(_db));
            }
            
            if (sqlite3_bind_text(pstmt, 1, [createdDateString UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            
            if (sqlite3_bind_int(pstmt, 2, orderNum) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            int success = 0;
            if ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
                weekReportObj.autoIncrementID = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
                isSusscess = YES;
            }
            if (success != SQLITE_ROW && success != SQLITE_DONE) {
                NSString * errorText = [NSString stringWithFormat:@"\n获取周报ID时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
                NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
                
                [self postErrorNotificationOfMessage:errorText
                                         errorDomain:DataBaseErrorDomain
                                           errorCode:DatabaseErrorCode];
            }
            if (sqlite3_step(pstmt) == SQLITE_ROW) {
                NSString * errorText = [NSString stringWithFormat:@"\n获取周报ID时重复的被自动忽略！"];
                [self postErrorNotificationOfMessage:errorText
                                         errorDomain:DataBaseErrorDomain
                                           errorCode:DatabaseErrorCode];
                
            }
            
            sqlite3_finalize(pstmt);
            pstmt = NULL;
            
        } else {
            NSString * errorText = @"\n获取周报ID时发生错误！";
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
            
            NSLog(@"can't get weekReport ID by orderNum and createdDate!");
            continue;
        }
        
    }
    return isSusscess;
    
}


- (BOOL)saveWeekReports:(NSArray *)weekReports {
    BOOL isSuccessful = NO;
    if ([weekReports count] > 0) {
        sqlite3_stmt * pstmt = NULL;
        const char * sqlWeekReportInsert = "INSERT INTO WeekReport (orderNum, createdDate, createdYear, projectID, projectName, requirementID, taskContent, normalTime, overTime, carFare, mealFee, otherFee, isBusinessTrip, taskType, alert, startTime, comment, weekNum) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        const char * sqlWeekReportUpdate = "UPDATE WeekReport set orderNum = ?, createdDate = ?, createdYear = ?, projectID = ?, projectName = ?, requirementID = ?, taskContent = ?, normalTime = ?, overTime = ?, carFare = ?, mealFee = ?, otherFee = ?, isBusinessTrip = ?, taskType = ?, alert = ?, startTime = ?, comment = ?, weekNum = ? where _ID = ?";
        
        for (FSWeekReportObject * obj in weekReports) {
            sqlite3_reset(pstmt);
            
            if (obj.autoIncrementID == nil) {
                if (sqlite3_prepare_v2(_db, sqlWeekReportInsert, -1, &pstmt, NULL) != SQLITE_OK) {
                    NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
                }
            } else {
                if (sqlite3_prepare_v2(_db, sqlWeekReportUpdate, -1, &pstmt, NULL) != SQLITE_OK) {
                    NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
                }
                if (sqlite3_bind_int(pstmt, 19, [obj.autoIncrementID intValue]) != SQLITE_OK) {
                    NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
                }
            }
            if (sqlite3_bind_int(pstmt, 1, [obj.orderNum intValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 2, [obj.createdDate UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 3, [obj.createdYear UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 4, [obj.projectID UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 5, [obj.projectName UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 6, [obj.requirementID UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 7, [obj.taskContent UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_double(pstmt, 8, [obj.normalTime doubleValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_double(pstmt, 9, [obj.overTime doubleValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_double(pstmt, 10, [obj.carFare doubleValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_double(pstmt, 11, [obj.mealFee doubleValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_double(pstmt, 12, [obj.otherFee doubleValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_int(pstmt, 13, [obj.isBusinessTrip intValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_int(pstmt, 14, [obj.taskType intValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_int(pstmt, 15, [obj.alert intValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 16, [obj.startTime UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_text(pstmt, 17, [obj.comment UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_int(pstmt, 18, [obj.weekNum intValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            
            int success = sqlite3_step(pstmt);
            if (success == SQLITE_DONE) {
                isSuccessful = YES;
            } else {
                NSString * errorText = [NSString stringWithFormat:@"\n保存周报时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
                [self postErrorNotificationOfMessage:errorText
                                         errorDomain:DataBaseErrorDomain
                                           errorCode:DatabaseErrorCode];
                
                NSLog(@"Error: failed to save weekreport object '%s'.", sqlite3_errmsg(_db));
            }
            sqlite3_finalize(pstmt);
            pstmt = NULL;
        }
        
    } else {
        NSString * errorText = @"\n试图保存空的周报，保存失败！";
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        NSLog(@"Error: try to save nil into sqlite.");
    }
    return isSuccessful;
}

- (BOOL)saveWeekSummary:(FSWeekSummaryObject *)weekSummary {
    BOOL isSuccessful = NO;
    if (weekSummary != nil) {
        sqlite3_stmt * pstmt = NULL;
        const char * sqlWeekSummaryInsert = "INSERT INTO WeekSummary (createdYear, weekNum, thisSummary, nextPlan) VALUES(?,?,?,?)";
        const char * sqlWeekSummaryUpdate = "UPDATE WeekSummary SET createdYear = ?, weekNum = ?, thisSummary = ?, nextPlan = ? where _ID = ?";
        if (weekSummary.autoIncrementID == nil) {
            if (sqlite3_prepare_v2(_db, sqlWeekSummaryInsert, -1, &pstmt, NULL) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
            }
        } else {
            if (sqlite3_prepare_v2(_db, sqlWeekSummaryUpdate, -1, &pstmt, NULL) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
            }
            if (sqlite3_bind_int(pstmt, 5, [weekSummary.autoIncrementID intValue]) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            
        }
        if (sqlite3_bind_text(pstmt, 1, [weekSummary.createdYear UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_bind_int(pstmt, 2, [weekSummary.weekNum intValue]) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_bind_text(pstmt, 3, [weekSummary.thisSummary UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_bind_text(pstmt, 4, [weekSummary.nextPlan UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        
        int success = sqlite3_step(pstmt);
        if (success == SQLITE_DONE) {
            isSuccessful = YES;
        } else {
            NSString * errorText = [NSString stringWithFormat:@"\n保存周报总结时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
            
            NSLog(@"Error: failed to save weekSummary object '%s'.", sqlite3_errmsg(_db));
        }
        sqlite3_finalize(pstmt);
        pstmt = NULL;
        
        
    } else {
        NSString * errorText = @"\n试图保存空的周报总结！";
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        NSLog(@"Error: try to insert nil into WeekSummary '%s'.", sqlite3_errmsg(_db));
    }
    return isSuccessful;
    
}

- (NSURL *)outputWeekReports:(NSArray *)weekReportsArray {
    NSURL * fileNameURL = nil;
    BOOL isSuccessful = YES;
    if ([weekReportsArray count] == 0) {
        isSuccessful = NO;
        NSString * errorText = @"\n尚未填写周报！";
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:OutPutReportErrorDomain
                                   errorCode:OutPutReportErrorCode];
        
    } else {
#if TARGET_OS_IPHONE
        NSString * exportDirectory = [DocumentDirectory stringByAppendingPathComponent:@"/Export"];
#else
        NSString * exportDirectory = [AppInDirectory stringByAppendingPathComponent:@"/Export"];
#endif
        
        BOOL outputDirectoryExist = [[NSFileManager defaultManager] createDirectoryAtPath:exportDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        if (!outputDirectoryExist) {
            NSString * errorText = @"\n导出目录创建失败，无法导出周报！";
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:OutPutReportErrorDomain
                                       errorCode:OutPutReportErrorCode];
            isSuccessful = NO;
        } else {
            NSString * version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
            FSWeekReportObject * weekReportObj = (FSWeekReportObject *)[weekReportsArray objectAtIndex:0];
            NSString * createdYear = weekReportObj.createdYear;
            NSString * createdWeek = [NSString stringWithFormat:@"%@", weekReportObj.weekNum];
            
            NSString * profileID = [[NSUserDefaults standardUserDefaults] valueForKey:kID];
            NSString * profileName = [[NSUserDefaults standardUserDefaults] valueForKey:kName];
            if (isEmptyString(profileID) || isEmptyString(profileName)) {
                NSString * errorText = @"\n个人资料不完整，无法导出周报！";
                [self postErrorNotificationOfMessage:errorText
                                         errorDomain:OutPutReportErrorDomain
                                           errorCode:OutPutReportErrorCode];
                isSuccessful = NO;
                
            } else {
                NSString * firstDayStringThisWeek = nil;
                
                GDataXMLElement * rootElement       = [GDataXMLNode elementWithName:@"root"];
                //child node
                GDataXMLElement * docType           = [GDataXMLNode elementWithName:@"doc-type" stringValue:@"week-report"];
                [rootElement addChild:docType];
                GDataXMLElement * docVersion        = [GDataXMLNode elementWithName:@"doc-version" stringValue:version];
                [rootElement addChild:docVersion];
                GDataXMLElement * reportPerson      = [GDataXMLNode elementWithName:@"report-person" stringValue:profileName];
                [rootElement addChild:reportPerson];
                GDataXMLElement * idNo              = [GDataXMLNode elementWithName:@"id-no" stringValue:profileID];
                [rootElement addChild:idNo];
                GDataXMLElement * reportYear        = [GDataXMLNode elementWithName:@"report-year" stringValue:createdYear];
                [rootElement addChild:reportYear];
                GDataXMLElement * reportWeek        = [GDataXMLNode elementWithName:@"report-week" stringValue:createdWeek];
                [rootElement addChild:reportWeek];
                
                //task list
                GDataXMLElement * taskList = [GDataXMLNode elementWithName:@"task-list"];
                
                //generate week reports xml data
                for (FSWeekReportObject * obj in weekReportsArray) {
                    if (firstDayStringThisWeek == nil) {
                        firstDayStringThisWeek = obj.firstDateStringThisWeek;
                        assert(!isEmptyString(firstDayStringThisWeek));
                    }
                    
                    GDataXMLElement * task = [GDataXMLNode elementWithName:@"task"];
                    assert(obj.createdDate.length > 10);
                    //child node of task
                    NSString * taskDateString = [obj.createdDate substringToIndex:10];
                    GDataXMLElement * taskDate      = [GDataXMLNode elementWithName:@"task-date"
                                                                        stringValue:taskDateString];
                    [task addChild:taskDate];
                    
                    GDataXMLElement * taskSeq       = [GDataXMLNode elementWithName:@"task-seq"
                                                                        stringValue:[NSString stringWithFormat:@"%@", obj.orderNum]];
                    [task addChild:taskSeq];
                    
                    GDataXMLElement * projID        = [GDataXMLNode elementWithName:@"proj-id"
                                                                        stringValue:obj.projectID];
                    [task addChild:projID];
                    
                    GDataXMLElement * szitID        = [GDataXMLNode elementWithName:@"szit-id"
                                                                        stringValue:obj.requirementID];
                    [task addChild:szitID];
                    
                    GDataXMLElement * taskMemo      = [GDataXMLNode elementWithName:@"task-memo"
                                                                        stringValue:obj.taskContent];
                    [task addChild:taskMemo];
                    
                    NSString * normalHourString     = [NSString stringWithFormat:@"%.2lf", [obj.normalTime doubleValue]];
                    GDataXMLElement * normalHour    = [GDataXMLNode elementWithName:@"normal-hour"
                                                                        stringValue:normalHourString];
                    [task addChild:normalHour];
                    
                    NSString * overTimeHourString   = [NSString stringWithFormat:@"%.2lf", [obj.overTime doubleValue]];
                    GDataXMLElement * overTimeHour  = [GDataXMLNode elementWithName:@"overtime-hour"
                                                                        stringValue:overTimeHourString];
                    [task addChild:overTimeHour];
                    
                    NSString * trafficFeeString     = [NSString stringWithFormat:@"%.2lf", [obj.carFare doubleValue]];
                    GDataXMLElement * trafficFee    = [GDataXMLNode elementWithName:@"traffic-fee"
                                                                        stringValue:trafficFeeString];
                    [task addChild:trafficFee];
                    
                    NSString * mealFeeString        = [NSString stringWithFormat:@"%.2lf", [obj.mealFee doubleValue]];
                    GDataXMLElement * mealFee       = [GDataXMLNode elementWithName:@"meal-fee"
                                                                        stringValue:mealFeeString];
                    [task addChild:mealFee];
                    
                    NSString * otherFeeString       = [NSString stringWithFormat:@"%.2lf", [obj.otherFee doubleValue]];
                    GDataXMLElement * otherFee      = [GDataXMLNode elementWithName:@"other-fee"
                                                                        stringValue:otherFeeString];
                    [task addChild:otherFee];
                    
                    NSString * outFlagString        = [NSString stringWithFormat:@"%d", obj.isBusinessTrip.intValue];
                    GDataXMLElement * outFlag       = [GDataXMLNode elementWithName:@"out_flag"
                                                                        stringValue:outFlagString];
                    [task addChild:outFlag];
                    
                    NSString * taskTypeString       = [NSString stringWithFormat:@"%d", obj.taskType.intValue];
                    GDataXMLElement * taskType      = [GDataXMLNode elementWithName:@"task_type"
                                                                        stringValue:taskTypeString];
                    [task addChild:taskType];
                    
                    GDataXMLElement * applyNo       = [GDataXMLNode elementWithName:@"apply_no"
                                                                        stringValue:obj.startTime];
                    [task addChild:applyNo];
                    
                    GDataXMLElement * memo          = [GDataXMLNode elementWithName:@"memo1"
                                                                        stringValue:obj.comment];
                    [task addChild:memo];
                    [taskList addChild:task];
                    
                }
                [rootElement addChild:taskList];
                
                GDataXMLElement * weekBrief         = [GDataXMLNode elementWithName:@"week-brief"];
                //child node of weekBrief
                FSWeekSummaryObject * weekSummaryObj = weekReportObj.weekSummaryObject;
                assert(weekSummaryObj);
                GDataXMLElement * weekSummary       = [GDataXMLNode elementWithName:@"week-summary"
                                                                        stringValue:weekSummaryObj.thisSummary];
                [weekBrief addChild:weekSummary];
                GDataXMLElement * nextPlan          = [GDataXMLNode elementWithName:@"next-plan"
                                                                        stringValue:weekSummaryObj.nextPlan];
                [weekBrief addChild:nextPlan];
                
                [rootElement addChild:weekBrief];
                
                
                GDataXMLDocument * xmlDocument = [[GDataXMLDocument alloc] initWithRootElement:rootElement];
                [xmlDocument setCharacterEncoding:@"utf-8"];
                NSData * xmlData = xmlDocument.XMLData;
                
                
                //generate file name
                NSDateFormatter * dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate * firstDate = [dateFormatter dateFromString:[firstDayStringThisWeek substringToIndex:10]];
                [dateFormatter setDateFormat:@"yyyyMMdd"];
                NSString * fileName = [NSString stringWithFormat:@"%@%@周报.xml", [dateFormatter stringFromDate:firstDate], profileName];
                fileName = [exportDirectory stringByAppendingPathComponent:fileName];
                
                if ([xmlData writeToFile:fileName atomically:YES]) {
                    isSuccessful = YES;
                    fileNameURL = [NSURL fileURLWithPath:fileName isDirectory:NO];
                } else {
                    isSuccessful = NO;
                    NSString * errorText = @"\n周报导出文件生成失败！";
                    [self postErrorNotificationOfMessage:errorText
                                             errorDomain:OutPutReportErrorDomain
                                               errorCode:OutPutReportErrorCode];
                }
            }
        }
        
        
    }
    
    
    return fileNameURL;
}

- (BOOL)removeWeekReport:(FSWeekReportObject *)weekReportObj fromReportsMutableArray:(NSMutableArray *)reports {
    BOOL isSuccessful = NO;
    
    if (weekReportObj.autoIncrementID != nil) {
        sqlite3_stmt * pstmt = NULL;
        const char * sqlWeekObjDelete = "DELETE FROM WeekReport where _ID = ?";
        if (sqlite3_prepare_v2(_db, sqlWeekObjDelete, -1, &pstmt, NULL) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
        }
        
        if (sqlite3_bind_int(pstmt, 1, [weekReportObj.autoIncrementID intValue]) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
        
        int success = sqlite3_step(pstmt);
        sqlite3_finalize(pstmt);
        pstmt = NULL;
        if (success == SQLITE_DONE) {
            isSuccessful = YES;
            [reports removeObject:weekReportObj];
        } else {
            NSString * errorText = [NSString stringWithFormat:@"\n删除周报时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
            
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
            
            
            NSLog(@"Error: failed to delete weekReport object '%s'.", sqlite3_errmsg(_db));
        }
        
        
    } else {
        //return directly if weekReportObj.autoIncrementID is nil
        NSString * errorText = @"\n删除周报发生错误，因未能获取周报ID！";
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        NSLog(@"Can not delete weekReport because there is no autoIncrementID.");
        
    }
    return isSuccessful;
}

- (NSArray *)projectInfosParsedByXMLFile:(NSURL *)fileURL {
    BOOL hasError = NO;
    NSMutableArray * projectInfoMuArray = [NSMutableArray arrayWithCapacity:100];
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfURL:fileURL] encoding:NSUTF8StringEncoding error:NULL];
    if (doc) {
        NSArray * projectList = [doc nodesForXPath:@"/root" error:NULL];
        if ([projectList count] == 1 && [[projectList objectAtIndex:0] isKindOfClass:[GDataXMLElement class]]) {
            GDataXMLElement * rootElement = [projectList objectAtIndex:0];
            //            NSArray * array1 = [rootElement elementsForName:@"doc-type"];
            //            NSArray * array2 = [rootElement elementsForName:@"doc-version"];
            NSArray * array3 = [rootElement elementsForName:@"proj-list"];
            if ([array3 count] == 1 && [[array3 objectAtIndex:0] isKindOfClass:[GDataXMLElement class]]) {
                GDataXMLElement * projListElement = [array3 objectAtIndex:0];
                NSArray * projListArray = [projListElement elementsForName:@"proj"];
                for (GDataXMLElement * obj in projListArray) {
                    @autoreleasepool {
                        FSProjectInfoObject * projInfoObj = [FSProjectInfoObject new];
                        //parse proj-id
                        NSArray * projIdArray = [obj elementsForName:@"proj-id"];
                        if ([projIdArray count] > 0) {
                            projInfoObj.projectID = [[projIdArray objectAtIndex:0] stringValue];
                        } else {
                            hasError = YES;
                            break;
                        }
                        //parse proj-name
                        NSArray * projNameArray = [obj elementsForName:@"proj-name"];
                        if ([projNameArray count] > 0) {
                            projInfoObj.projectName = [[projNameArray objectAtIndex:0] stringValue];
                        } else {
                            hasError = YES;
                            break;
                        }
                        [projectInfoMuArray addObject:projInfoObj];
                    }
                }
            }
        }
        if (hasError) {
            projectInfoMuArray = nil;
            
            [self postErrorNotificationOfMessage:@"XML文件内容有缺失，拒绝导入！"
                                     errorDomain:XMLParseErrorDomain
                                       errorCode:XMLParseErrorCode];
            
        }
        return projectInfoMuArray;
    }
    return nil;
}

- (void) saveInputProjectInfos:(NSArray *)projectInfos {
    for (FSProjectInfoObject * projectInfoObj in projectInfos) {
        [self saveProjectInfo:projectInfoObj];
    }
}


- (BOOL) saveProjectInfo:(FSProjectInfoObject *)projectInfoObj {
    BOOL isSuccessful = NO;
    sqlite3_stmt * pstmt = NULL;
    
    sqlite3_reset(pstmt);
    
    const char * sqlProjectInfoInsert = "INSERT INTO ProjectsInfo (projectID, projectName, isChecked, startDate, startTime) VALUES(?,?,?,?,?)";
    const char * sqlProjectInfoUpdate = "UPDATE ProjectsInfo SET projectID = ?, projectName = ?, isChecked = ?, startDate = ?, startTime = ? where _ID = ?";
    
    if (projectInfoObj.autoIncrementID == nil) {
        //insert
        if (sqlite3_prepare_v2(_db, sqlProjectInfoInsert, -1, &pstmt, NULL) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
        }
    } else {
        //update
        if (sqlite3_prepare_v2(_db, sqlProjectInfoUpdate, -1, &pstmt, NULL) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
        }
        if (sqlite3_bind_int(pstmt, 6, [projectInfoObj.autoIncrementID intValue]) != SQLITE_OK) {
            NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
        }
    }
    if (sqlite3_bind_text(pstmt, 1, [projectInfoObj.projectID UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    if (sqlite3_bind_text(pstmt, 2, [projectInfoObj.projectName UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    if (sqlite3_bind_int(pstmt, 3, [projectInfoObj.isChecked intValue])) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    if (sqlite3_bind_text(pstmt, 4, [projectInfoObj.startDate UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    if (sqlite3_bind_text(pstmt, 5, [projectInfoObj.startTime UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
    }
    if (sqlite3_step(pstmt) == SQLITE_DONE) {
        isSuccessful = YES;
    } else {
        NSString * errorText = [NSString stringWithFormat:@"\n导入的项目信息存入数据库时发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
        
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        
        NSLog(@"Error: failed to save project info object '%s'.", sqlite3_errmsg(_db));
    }
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    
    return isSuccessful;
}

- (BOOL)retrieveIDFromDatabaseByProjectsInfo:(NSArray *)projectsInfo {
    BOOL isSusscess = NO;
    sqlite3_stmt * pstmt = NULL;
    
    for (FSProjectInfoObject * projectInfo in projectsInfo) {
        if (!isEmptyString(projectInfo.projectID) && !isEmptyString(projectInfo.projectName)) {
            
            char * sql = "select * from ProjectsInfo where projectID = ? and projectName = ?";
            if (sqlite3_prepare_v2(_db, sql, -1, &pstmt, NULL) != SQLITE_OK) {
                NSAssert(0, @"Error:preparing statement in retrieveIDFromDatabaseByProjectsInfo, '%s'", sqlite3_errmsg(_db));
            }
            
            if (sqlite3_bind_text(pstmt, 1, [projectInfo.projectID UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            
            if (sqlite3_bind_text(pstmt, 2, [projectInfo.projectName UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
                NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(_db));
            }
            int success = 0;
            if ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
                projectInfo.autoIncrementID = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
                isSusscess = YES;
            }
            if (success != SQLITE_ROW && success != SQLITE_DONE) {
                NSString * errorText = [NSString stringWithFormat:@"\n获取项目信息ID时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
                NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
                
                [self postErrorNotificationOfMessage:errorText
                                         errorDomain:DataBaseErrorDomain
                                           errorCode:DatabaseErrorCode];
            }
            if (sqlite3_step(pstmt) == SQLITE_ROW) {
                NSString * errorText = [NSString stringWithFormat:@"\n获取项目信息ID时重复的被自动忽略！"];
                [self postErrorNotificationOfMessage:errorText
                                         errorDomain:DataBaseErrorDomain
                                           errorCode:DatabaseErrorCode];
                
            }
            
            sqlite3_finalize(pstmt);
            pstmt = NULL;
            
        } else {
            NSString * errorText = @"\n获取项目信息ID时发生错误！";
            [self postErrorNotificationOfMessage:errorText
                                     errorDomain:DataBaseErrorDomain
                                       errorCode:DatabaseErrorCode];
            
            NSLog(@"can't get weekReport ID by orderNum and createdDate!");
            continue;
        }
        
    }
    return isSusscess;
    
}

- (NSArray *)selectProjectsInfoIsChecked {
    NSMutableArray * projectsCheckedMuArray = [NSMutableArray arrayWithCapacity:20];
    sqlite3_stmt * pstmt = NULL;
    const char * sqlCheckedProject = "select * from ProjectsInfo where isChecked = 1";
    if (sqlite3_prepare_v2(_db, sqlCheckedProject, -1, &pstmt, NULL) != SQLITE_OK) {
        NSAssert(0, @"Error:preparing statement in selectProjectsInfoForWeekReports, '%s'", sqlite3_errmsg(_db));
    }
    
    int success = 0;
    while ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
        @autoreleasepool {
            FSProjectInfoObject * projectInfoObj = [FSProjectInfoObject new];
            projectInfoObj.autoIncrementID  = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
            projectInfoObj.projectID        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 1)]];
            projectInfoObj.projectName      = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 2)]];
            projectInfoObj.isChecked        = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 3)];
            projectInfoObj.startDate        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 4)]];
            projectInfoObj.startTime        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 5)]];
            [projectsCheckedMuArray addObject:projectInfoObj];
        }
    }
    if (success != SQLITE_DONE) {
        NSString * errorText = [NSString stringWithFormat:@"\n获取参与的项目信息时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        NSLog(@"Error: failed to execute query with message '%s'.", sqlite3_errmsg(_db));
        
    }
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    
    return projectsCheckedMuArray;
}

- (NSArray *)selectAllProjectsInfos {
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:200];
    sqlite3_stmt * pstmt = NULL;
    
    const char * sqlWeekReport = "SELECT * FROM ProjectsInfo";
    if (sqlite3_prepare_v2(_db, sqlWeekReport, -1, &pstmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
    }
    
    int success = 0;
    while ((success = sqlite3_step(pstmt)) == SQLITE_ROW) {
        @autoreleasepool {
            FSProjectInfoObject * projectInfoObj = [FSProjectInfoObject new];
            projectInfoObj.autoIncrementID  = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 0)];
            projectInfoObj.projectID        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 1)]];
            projectInfoObj.projectName      = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 2)]];
            projectInfoObj.isChecked        = [NSNumber numberWithInt:sqlite3_column_int(pstmt, 3)];
            projectInfoObj.startDate        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 4)]];
            projectInfoObj.startTime        = [NSString stringWithUTF8String:[self makeResultLegal:sqlite3_column_text(pstmt, 5)]];
            [results addObject:projectInfoObj];
        }
    }
    if (success != SQLITE_DONE) {
        NSString * errorText = [NSString stringWithFormat:@"\n查询项目信息时数据库发生错误！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
        
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
        
        NSLog(@"Error: failed to execute query project info sql with message '%s'.", sqlite3_errmsg(_db));
    }
    
    // Destroy the query for the next use.
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    
    return results;
    
}

- (BOOL)clearAllProjectsInfoInDatabase {
    BOOL isSuccessful = NO;
    sqlite3_stmt * pstmt = NULL;
    //remove
    const char * sqlClearAllProjectInfos = "DELETE FROM ProjectsInfo";
    if (sqlite3_prepare_v2(_db, sqlClearAllProjectInfos, -1, &pstmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_db));
    }
    
    int success = 0;
    if((success = sqlite3_step(pstmt)) != SQLITE_DONE) {
        NSString * errorText = [NSString stringWithFormat:@"\n清空项目信息表时数据库出错！\n来自数据库抛出的消息：%s", sqlite3_errmsg(_db)];
        [self postErrorNotificationOfMessage:errorText
                                 errorDomain:DataBaseErrorDomain
                                   errorCode:DatabaseErrorCode];
    } else {
        isSuccessful = YES;
    }
    
    sqlite3_finalize(pstmt);
    pstmt = NULL;
    return isSuccessful;
}

- (BOOL)sendToServer:(const char *)ipAdress port:(NSUInteger)port withFile:(NSURL *)fileURL {
    if (fileURL == nil) {
        return NO;
    }
    BOOL success = YES;
    NSString * fileName = [[fileURL lastPathComponent] stringByAppendingString:@"\r\n"];
    //    CFStringRef cfFileName = CFBridgingRetain([fileName stringByAppendingString:@"\r\n"]);
    //    size_t len = CFStringGetLength(cfFileName) + 10;
    //    char * cFileName = (char *)malloc(len);
    //    CFStringGetCString(cfFileName, cFileName, len, kCFStringEncodingGB_18030_2000);
    //    CFRelease(cfFileName);
    
    NSString * createdDateString = [[fileName substringToIndex:8] stringByAppendingString:@"\r\n"];
    //    CFStringRef cfCreatedDateString = CFBridgingRetain([createdDateString stringByAppendingString:@"\r\n"]);
    //    len = CFStringGetLength(cfCreatedDateString) + 10;
    //    char * cCreatedDateString = (char *)malloc(len);
    //    CFStringGetCString(cfCreatedDateString, cCreatedDateString, len, kCFStringEncodingGB_18030_2000);
    //    CFRelease(cfCreatedDateString);
    
    NSString * name = [[[NSUserDefaults standardUserDefaults] valueForKey:kName] stringByAppendingString:@"\r\n"];
    //    CFStringRef cfName = CFBridgingRetain([name stringByAppendingString:@"\r\n"]);
    //    len = CFStringGetLength(cfName) + 10;
    //    char * cName = (char *)malloc(len);
    //    CFStringGetCString(cfName, cName, len, kCFStringEncodingGB_18030_2000);
    //    CFRelease(cfName);
    
    assert(!isEmptyString(fileName) && !isEmptyString(createdDateString) && !isEmptyString(name));
    //    NSLog(@"fileName:%@, createdDateString:%@, name:%@", cfFileName, cfCreatedDateString, cfName);
    
    NSData * data = [NSData dataWithContentsOfURL:fileURL];
    const void * dataBytes = [data bytes];
    
    //send to server
    int sockfd;
    size_t numbytes;
    size_t recLen = 2048;
    char buf[recLen];
    struct sockaddr_in their_addr;
    
    if((sockfd = socket(AF_INET,SOCK_STREAM,0))==-1)
    {
        perror("socket");
        [self postErrorNotificationOfMessage:@"初始化连接失败！" errorDomain:SocketErrorDomain errorCode:SocketErrorCode];
        return NO;
    }
    
    their_addr.sin_family = AF_INET;
    their_addr.sin_port = htons(port);
    //// their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    /* inet_aton: Convert Internet host address from numbers-and-dots notation in CP
     into binary data and store the result in the structure INP.  */
    if(inet_pton(AF_INET, ipAdress, &their_addr.sin_addr) <= 0)
    {
        [self postErrorNotificationOfMessage:@"网络连接错误！请检查网络或本系统参数设置" errorDomain:SocketErrorDomain errorCode:SocketErrorCode];
        return NO;
    }
    //inet_aton( "192.168.114.171", &their_addr.sin_addr );
    bzero(&(their_addr.sin_zero),8);
    struct timeval timeout = {
        .tv_sec = 6.0,
        .tv_usec = 0.0
    };
    
    if(setsockopt(sockfd,SOL_SOCKET,SO_SNDTIMEO,(void *)&timeout,sizeof(timeout))== -1)
    {
        return NO;
    }
    
    if(setsockopt(sockfd,SOL_SOCKET,SO_RCVTIMEO,(void *)&timeout,sizeof(timeout))== -1)
    {
        return NO;
    }
    ////∫Õ∑˛ŒÒ∆˜Ω®¡¢¡¨Ω”
    if(connect(sockfd,(struct sockaddr *)&their_addr,sizeof(struct sockaddr))==-1)
    {
        perror("connect");
        return NO;
    }
    
    if(send(sockfd,"upfile\r\n", 8, 0)==-1)
    {
        perror("send upfile");
        return NO;
    }
    if(send(sockfd, [name UTF8String], [name length], 0)==-1)
    {
        perror("send person name");
        return NO;
    }
    if(send(sockfd, [createdDateString UTF8String], [createdDateString length], 0)==-1)
    {
        perror("send createdDataString");
        return NO;
    }
    if(send(sockfd, [fileName UTF8String], [fileName length], 0)==-1)
    {
        perror("send fileName");
        return NO;
    }
    
    NSMutableData * muData = [NSMutableData dataWithData:data];
    [muData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(send(sockfd, [muData bytes], [muData length], 0)==-1)
    {
        perror("send file data");
        return NO;
    }
    
    if(send(sockfd, "END\r\n", 5, 0)==-1)
    {
        return NO;
    }
    
    //接收服务器返回
    if((numbytes = recv(sockfd, buf, recLen, 0))==-1)
    {
        perror("recv");
        return NO;
    }
    printf("Recive from server:%s\n",buf);
    
    ////πÿ±’socket
    close(sockfd);
    
    
    //    free(cFileName);
    //    free(cCreatedDateString);
    //    free(cName);
    
    return success;
}


- (NSInteger) weekNumOfDate:(NSDate *) selectedDate{
    return [[self.gregorianCalendar components:NSWeekCalendarUnit fromDate:selectedDate] week];
}

- (NSArray *)firstAndLastDayStringByDate:(NSDate *)selectedDate {
    assert(selectedDate);
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd cccc"];
    return [self firstAndLastDayStringByDate:selectedDate withFormatter:self.dateFormatter];
}

- (NSArray *)firstAndLastDayStringByDate:(NSDate *)selectedDate withFormatter:(NSDateFormatter *)formatter {
    assert(selectedDate);
    assert(formatter);
    NSUInteger currentWeekDay = [self.gregorianCalendar ordinalityOfUnit:NSWeekdayCalendarUnit
                                                                  inUnit:NSWeekCalendarUnit
                                                                 forDate:selectedDate];
    //cast unsigned long to long
    NSDate * firstDayDate = [selectedDate dateByAddingTimeInterval:-24 * 3600 * (long)(currentWeekDay - 1)];
    NSDate * lastDayDate = [selectedDate dateByAddingTimeInterval:24 * 3600 * (long)(7 - currentWeekDay)];
    if (currentWeekDay == 1) {
        firstDayDate = selectedDate;
    } else if (currentWeekDay == 7) {
        lastDayDate = selectedDate;
    }
    
    NSString * firstDayString = [formatter stringFromDate:firstDayDate];
    NSString * lastDayString = [formatter stringFromDate:lastDayDate];
    return @[firstDayString, lastDayString];
}

@end

NSString * const DefaultServerAddress           = @"http://192.168.23.123:8080/FSWeekReport/uploadFile";

NSString * const ErrorOccuredNotification       = @"ErrorOccuredNotification";
NSString * const NeedSaveNotification           = @"NeedSaveNotification";

NSString * const XMLParseErrorDomain            = @"XMLParseErrorDomain";
NSString * const DataBaseErrorDomain            = @"DataBaseErrorDomain";
NSString * const OutPutReportErrorDomain        = @"OutPutReportErrorDomain";
NSString * const SocketErrorDomain              = @"SocketErrorDomain";


NSString * const LocalTimeZone = @"Asia/Shanghai";
NSString * const LocaleIdentifier = @"zh-Hans";
