//
//  FSMyWeekReportView.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#define ColumnDateTag               100
#define ColumnOrderNumTag           101
#define ColumnProjectNameTag        102
#define ColumnTaskContentTag        103
#define ColumnRegularTimeTag        104
#define ColumnOverTimeTag           105
#define ColumnTrafficCostTag        106
#define ColumnFoodCostTag           107
#define ColumnWorkTripTag           108

#define IdentifierDate            @"DateCellViewID"
#define IdentifierOrder           @"OrderCellViewID"
#define IdentifierProject         @"ProjcetCellViewID"
#define IdentifierTask            @"TaskCellViewID"
#define IdentifierRegular         @"RegTimeCellViewID"
#define IdentifierOverTime        @"OverTimeCellViewID"
#define IdentifierTrafficCost     @"TrafficCostCellViewID"
#define IdentifierFoodCost        @"FoodCostCellViewID"
#define IdentifierWorkTrip        @"WorkTripCellViewID"

#import "FSMyWeekReportView.h"
#import "FSDatePickerViewController.h"
#import <LogicForMac.h>

#import "FSAppDelegate.h"

@interface FSMyWeekReportView () {
    NSInteger _weekNum;
    BOOL _needReloadTableViewForLoadDataFromDataBase;
    BOOL _firstLoadRefreshDateButton;

}

@property FSDatePickerViewController * myDatePicker;
@property NSDateFormatter * dateFormatter;
@property NSDate * selectedDate;
@property LogicForMac * logicForMac;

@property NSMutableArray * weekReportsMuArray;
@property NSArray * projectNameInfos;
@property NSArray * mealFeeArray;
@property FSWeekSummaryObject * weekSummary;
@property NSString * firstDayString;
@property NSString * lastDayString;
@property NSURL * weekReportExportedURL;
@property FSProjectInfoObject * recentProj;

@end

@implementation FSMyWeekReportView

#pragma mark - Override

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //do something after view did load

        self.selectedDate = [NSDate date];
        self.dateFormatter = [NSDateFormatter new];
        self.weekReportsMuArray = [NSMutableArray arrayWithCapacity:20];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:LocalTimeZone]];
        [self.dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:LocaleIdentifier]];
        self.logicForMac = [LogicForMac new];
        
        self.projectNameInfos = [self.logicForMac selectProjectsInfoIsChecked];
        if ([self.projectNameInfos count] > 0) {
            self.recentProj = [self.projectNameInfos objectAtIndex:0];
        }
        self.mealFeeArray = @[@(0), @(30)];
                
        _weekNum = [self.logicForMac weekNumOfDate:self.selectedDate];
        [self calculateFirstAndLastDayString];

        _needReloadTableViewForLoadDataFromDataBase = YES;
        _firstLoadRefreshDateButton = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(projectCheckingChanged:)
                                                     name:ProjectCheckingChangedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(needSaveCalledNotification:)
                                                     name:NeedSaveNotification
                                                   object:nil];
        
/*
 NSLog(@"correct weekday number: %li", (unsigned long)[calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[NSDate date]]);
 NSLog(@"week number: %ld", [[calendar components:NSWeekCalendarUnit fromDate:[NSDate date]] week]);
 
 NSLog(@"week number: %ld", [[calendar components:NSWeekOfYearCalendarUnit fromDate:[NSDate date] ] weekOfYear]);
*/
        
    }
    return self;

}

- (void)drawRect:(NSRect)dirtyRect {
    //if the custom view is a direct NSView subclass, we do not need to call super's implementation
    if (_firstLoadRefreshDateButton) {
        _firstLoadRefreshDateButton = NO;
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * currentDateString = [NSString stringWithFormat:@"日期：%@", [self.dateFormatter stringFromDate:self.selectedDate]];
        [self.dateButton setTitle:currentDateString];
        

        
    }
    //reload data for tableview after NSView loaded
    if (_needReloadTableViewForLoadDataFromDataBase) {
        [self loadDataFromDatabase];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.reportTableView.delegate = nil;
    self.reportTableView.dataSource = nil;
    self.myDatePicker.delegate = nil;
    self.thisSummaryTextView = nil;
    self.nextPlanTextView = nil;
}

#pragma mark - private

- (void) calculateFirstAndLastDayString {
    NSArray * results = [self.logicForMac firstAndLastDayStringByDate:self.selectedDate];
    assert([results count] == 2);
    self.firstDayString = [results objectAtIndex:0];
    self.lastDayString = [results objectAtIndex:1];
    NSLog(@"firstDayString:%@, lastDayString:%@", self.firstDayString, self.lastDayString);

}

- (void) loadDataFromDatabase {
    _needReloadTableViewForLoadDataFromDataBase = NO;
    NSLog(@"week number: %ld", _weekNum);
    
    [self.weekReportsMuArray removeAllObjects];
    [self.weekReportsMuArray setArray: [self.logicForMac selectAllWeekReportFromDateString:self.firstDayString toDateString:self.lastDayString]];
    
    for (FSWeekReportObject * obj in self.weekReportsMuArray) {
        obj.firstDateStringThisWeek = self.firstDayString;
        obj.lastDateStringThisWeek = self.lastDayString;
    }
    
    if ([self.weekReportsMuArray count] > 0) {
        self.weekSummary = [[self.weekReportsMuArray objectAtIndex:0] weekSummaryObject];
        if (self.weekSummary == nil) {
            [self createNewWeekSummary];
        }
        [self reloadSummaryTextView];
    } else {
        NSString * createdYear = [self.lastDayString substringToIndex:4];
        assert(!isEmptyString(createdYear));
        self.weekSummary = [self.logicForMac selectOneWeekSummaryByCreatedYear:createdYear weekNum:@(_weekNum)];
    }
    [self refreshNormalTimeLabel];
    [self.reportTableView reloadData];
    
    
}

- (void)createNewWeekSummary {
    self.weekSummary = [FSWeekSummaryObject new];
    //in order to let me know which year the target week belongs to.
    assert(!isEmptyString(self.lastDayString));
    self.weekSummary.createdYear = [self.lastDayString substringToIndex:4];
    self.weekSummary.weekNum = @(_weekNum);
    [self.logicForMac saveWeekSummary:self.weekSummary];
    //write the ID into weekSummary object, in order to execute SQL UPDATE
    [self.logicForMac retrieveIDFromDatabaseByWeekSummary:self.weekSummary];
    
    for (FSWeekReportObject * obj in self.weekReportsMuArray) {
        obj.weekSummaryObject = self.weekSummary;
    }
}

- (void) reloadSummaryTextView {
    self.thisSummaryTextView.string = @"";
    self.nextPlanTextView.string = @"";

    if (!isEmptyString(self.weekSummary.thisSummary)) {
        self.thisSummaryTextView.string = self.weekSummary.thisSummary;
    }
    if (!isEmptyString(self.weekSummary.nextPlan)) {
        self.nextPlanTextView.string = self.weekSummary.nextPlan;
    } 
}

//need check for saving data, needn't check for removing tableview row and refreshing order num
- (BOOL) retrieveDataFromTableViewControlsNeedCheckData:(BOOL)needCheck {
    if ([self.weekReportsMuArray count] == 0) {
        return NO;
    }
    //need save before quit app
    [(FSAppDelegate *)[NSApp delegate] setNeedSave:YES];
    __block BOOL canSave = YES;
    __block double normalTimeSum = 0.0;
    //define a temp array to change weekReportsMuArray after confirming that all control values are legal
    NSMutableArray * newMuArray = [[NSMutableArray alloc] initWithArray:self.weekReportsMuArray copyItems:YES];
    
    [self.reportTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        if (canSave) {
            FSWeekReportObject * weekReport = [newMuArray objectAtIndex:row];
            //column 0
            NSTableCellView * cellView0 = [rowView viewAtColumn:0];
            NSTextField * dateTextField = (NSTextField *)[cellView0 viewWithTag:ColumnDateTag];
            weekReport.createdDate = [dateTextField.cell title];
            assert([dateTextField.cell title]);
            //column 1
            NSTableCellView * cellView1 = [rowView viewAtColumn:1];
            NSTextField * orderNumTextField = (NSTextField *)[cellView1 viewWithTag:ColumnOrderNumTag];
            int orderNum = [[orderNumTextField.cell title] intValue];
            weekReport.orderNum = [NSNumber numberWithInt:orderNum];
            
            //column 2
            NSTableCellView * cellView2 = [rowView viewAtColumn:2];
            NSPopUpButton * popupButton = (NSPopUpButton *)[cellView2 viewWithTag:ColumnProjectNameTag];
            NSInteger selectedIndex = [popupButton indexOfSelectedItem];
            if (selectedIndex > 0 && selectedIndex < [self.projectNameInfos count]) {
                FSProjectInfoObject * selectedProjectInfo = [self.projectNameInfos objectAtIndex:selectedIndex];
                weekReport.projectName = [selectedProjectInfo projectName];
                weekReport.projectID = [selectedProjectInfo projectID];
            } else {
             //若weekReport存在项目名称，然后手动选择了空行或者该项目已不在当前列表中，则忽略，不做任何操作
             //没填或填入的项目名称不在列表内，数据都不合法，如需check则会弹出警告要求填写
             //若是很久以前的周报，项目可能没有勾选参加，这时显示空，但不覆盖项目信息对象中保存过的项目id和名称。
                NSString * errorText = [NSString stringWithFormat:@"%@的第%d项'项目名称'不合法，请在列表中选择！", weekReport.createdDate, weekReport.orderNum.intValue];
                if (isEmptyString(weekReport.projectName)) {
                    errorText = [NSString stringWithFormat:@"%@的第%d项'项目名称'为空，请填写！", weekReport.createdDate, weekReport.orderNum.intValue];
                }
                if (needCheck) {
                    [NSAlert showErrorMessage:errorText];
                    canSave = NO;
                    return;
                }
            }
       
            //column 3
            NSTableCellView * cellView3 = [rowView viewAtColumn:3];
            NSTextField * taskContentTextField = (NSTextField *)[cellView3 viewWithTag:ColumnTaskContentTag];
            NSString * taskContent = [self replaceXMLSensitiveWords:[taskContentTextField.cell title]];
            weekReport.taskContent = taskContent;
            if (needCheck && isEmptyString(taskContent)) {
                [NSAlert showErrorMessage:[NSString stringWithFormat:@"%@的第%d项'任务内容'为空，请填写！", weekReport.createdDate, weekReport.orderNum.intValue]];
                canSave = NO;
                return;
            }
            
            
            //column 4
            NSTableCellView * cellView4 = [rowView viewAtColumn:4];
            NSTextField * normalTimeTextField = (NSTextField *)[cellView4 viewWithTag:ColumnRegularTimeTag];
            NSString * normalTimeString = [normalTimeTextField.cell title];
            weekReport.normalTime = @([normalTimeString doubleValue]);
            if (isEmptyString(normalTimeString)) {
                [normalTimeTextField.cell setTitle:@"0.0"];
                if (needCheck) {
                    [NSAlert showErrorMessage:[NSString stringWithFormat:@"%@的第%d项'常时'为空，将被自动设置为0.0！", weekReport.createdDate, weekReport.orderNum.intValue]];
                    canSave = NO;
                    return;
                }
            }
            normalTimeSum += [normalTimeString doubleValue];
            
            //column 5
            NSTableCellView * cellView5 = [rowView viewAtColumn:5];
            
            NSTextField * overTimeTextField = (NSTextField *)[cellView5 viewWithTag:ColumnOverTimeTag];
            NSString * overTimeString = [overTimeTextField.cell title];
            if (!isEmptyString(overTimeString)) {
                weekReport.overTime = @([overTimeString doubleValue]);
            } else {
                weekReport.overTime = @0.0;
            }
            
            //column 6
            NSTableCellView * cellView6 = [rowView viewAtColumn:6];
            NSTextField * carFeeTextField = (NSTextField *)[cellView6 viewWithTag:ColumnTrafficCostTag];
            NSString * carFeeString = [carFeeTextField.cell title];
            if (!isEmptyString(carFeeString)) {
                weekReport.carFare = @([carFeeString doubleValue]);
            } else {
                weekReport.carFare = @0.0;
            }
            
            //column 7
            NSTableCellView * cellView7 = [rowView viewAtColumn:7];
            NSComboBox  * mealFeeComboBox = (NSComboBox *)[cellView7 viewWithTag:ColumnFoodCostTag];
            selectedIndex = mealFeeComboBox.indexOfSelectedItem;
            if (selectedIndex > 0 && selectedIndex < [mealFeeComboBox numberOfItems]) {
                weekReport.mealFee = [self.mealFeeArray objectAtIndex:selectedIndex];
            } else {
                weekReport.mealFee = [self.mealFeeArray objectAtIndex:0];
            }
            
            
            //column 8
            NSTableCellView * cellView8 = [rowView viewAtColumn:8];
            NSComboBox * bizTripComboBox = (NSComboBox *)[cellView8 viewWithTag:ColumnWorkTripTag];
            NSInteger isBizTrip = [bizTripComboBox indexOfSelectedItem];
            weekReport.isBusinessTrip = @(isBizTrip);

        }
    }];
    //to change weekReportsMuArray after confirming that all control values are legal
    self.weekReportsMuArray = newMuArray;
    BOOL isLegalNormalTime = [self refreshNormalTimeLabel];
    if (needCheck && !isLegalNormalTime) {
        if (canSave) {
            //if cansave checking is legal without normal time sum, then show this error alert
            [NSAlert showErrorMessage:@"日常时总和必须为8小时，请检查！"];
            canSave = NO;
        }
    }
    return canSave;
}

- (BOOL) refreshNormalTimeLabel {
    BOOL isLegal = YES;
    double mondayTime       = 0.0;
    double tuesdayTime      = 0.0;
    double wednesdayTime    = 0.0;
    double thurdayTime      = 0.0;
    double fridayTime       = 0.0;
    BOOL needShowMon        = NO;
    BOOL needShowTues       = NO;
    BOOL needShowWednes     = NO;
    BOOL needShowThurs      = NO;
    BOOL needShowFri        = NO;

    
    for (FSWeekReportObject * weekReportObj in self.weekReportsMuArray) {
        if ([weekReportObj.createdDate rangeOfString:@"一" options:NSBackwardsSearch].location != NSNotFound) {
            mondayTime      += [weekReportObj.normalTime doubleValue];
            needShowMon     = YES;
        } else if ([weekReportObj.createdDate rangeOfString:@"二" options:NSBackwardsSearch].location != NSNotFound) {
            tuesdayTime     += [weekReportObj.normalTime doubleValue];
            needShowTues    = YES;
        } else if ([weekReportObj.createdDate rangeOfString:@"三" options:NSBackwardsSearch].location != NSNotFound) {
            wednesdayTime   += [weekReportObj.normalTime doubleValue];
            needShowWednes  = YES;
        } else if ([weekReportObj.createdDate rangeOfString:@"四" options:NSBackwardsSearch].location != NSNotFound) {
            thurdayTime     += [weekReportObj.normalTime doubleValue];
            needShowThurs   = YES;
        } else if ([weekReportObj.createdDate rangeOfString:@"五" options:NSBackwardsSearch].location != NSNotFound) {
            fridayTime      += [weekReportObj.normalTime doubleValue];
            needShowFri     = YES;
        }
    }
    NSMutableString * normalTimeString = [NSMutableString stringWithString:@"不合法常时: "];
    if (needShowMon && mondayTime != 8.0) {
        [normalTimeString appendFormat:@"周一 (%.1lf)  ", mondayTime];
        isLegal = NO;
    }
    if (needShowTues && tuesdayTime != 8.0) {
        [normalTimeString appendFormat:@"周二 (%.1lf)  ", tuesdayTime];
        isLegal = NO;
    }
    if (needShowWednes && wednesdayTime != 8.0) {
        [normalTimeString appendFormat:@"周三 (%.1lf)  ", wednesdayTime];
        isLegal = NO;
    }
    if (needShowThurs && thurdayTime != 8.0) {
        [normalTimeString appendFormat:@"周四 (%.1lf)  ", thurdayTime];
        isLegal = NO;
    }
    if (needShowFri && fridayTime != 8.0) {
        [normalTimeString appendFormat:@"周五 (%.1lf)  ", fridayTime];
        isLegal = NO;
    }
    if (isLegal) {
        [normalTimeString setString:@"常时校验合法"];
    }
    [self.normalTimeLabel.cell setTitle:normalTimeString];
    return isLegal;
}

- (void) refreshOrder {
    if ([self.weekReportsMuArray count] > 0) {
        FSWeekReportObject * reportObj = [self.weekReportsMuArray objectAtIndex:0];
        NSString * reportDate = [reportObj createdDate];
        NSInteger orderNum = 1;
        reportObj.orderNum = @(orderNum);
        for (int i = 1; i < [self.weekReportsMuArray count]; i ++) {
            @autoreleasepool {
                NSString * ReportDateTemp = [(FSWeekReportObject *)[self.weekReportsMuArray objectAtIndex:i] createdDate];
                if ([reportDate isEqualToString:ReportDateTemp]) {
                    [(FSWeekReportObject *)[self.weekReportsMuArray objectAtIndex:i] setOrderNum:@(++orderNum)];
                } else {
                    reportObj = [self.weekReportsMuArray objectAtIndex:i];
                    reportDate = [reportObj createdDate];
                    orderNum = 1;
                    reportObj.orderNum = @(orderNum);
                }
            }
        }
    }
}

- (NSString *)replaceXMLSensitiveWords:(NSString *)words {
    NSString * result = words;
    result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"【"];
    result = [result stringByReplacingOccurrencesOfString:@">" withString:@"】"];
    result = [result stringByReplacingOccurrencesOfString:@"&" withString:@"、"];
    return result;
}

- (void) save {
    [self.logicForMac saveWeekReports:self.weekReportsMuArray];
    [self.logicForMac retrieveIDFromDatabaseByWeekReports:self.weekReportsMuArray];
    if (self.weekSummary != nil) {
        self.weekSummary.thisSummary = [self replaceXMLSensitiveWords: self.thisSummaryTextView.string];
        self.weekSummary.nextPlan = [self replaceXMLSensitiveWords: self.nextPlanTextView.string];
        [self.logicForMac saveWeekSummary:self.weekSummary];
    }
    [(FSAppDelegate *)[NSApp delegate] setNeedSave:NO];
}

- (void)commitToServer {
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setDirectoryURL:self.weekReportExportedURL];
    [panel setTitle:@"上传周报"];
    @try {
        id obj = [[[[[panel contentView] subviews] objectAtIndex:3] subviews] objectAtIndex:1];
        if ([obj isKindOfClass:[NSButton class]]) {
            NSString * currentTitle = [obj title];
            if ([currentTitle isEqualToString:@"打开"]) {
                [obj setTitle:@"上传"];
            } else if ([currentTitle rangeOfString:@"pen"].location != NSNotFound){
                [obj setTitle:@"Upload"];
            }
        }
    }
    @catch (NSException *exception) {

    }
    if ([panel runModal] == 1) {
        NSURL * fileURL = panel.URL;
        NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
        
        NSString * fileName = [fileURL lastPathComponent];
        NSString * createdDateString = [fileName substringToIndex:8];
        NSString * name = [[NSUserDefaults standardUserDefaults] valueForKey:kName];
        assert(!isEmptyString(fileName) && !isEmptyString(createdDateString) && !isEmptyString(name));

        NSString * serverURLString = [[NSUserDefaults standardUserDefaults] valueForKey:kServerAddress];
        if (isEmptyString(serverURLString)) {
            serverURLString = DefaultServerAddress;
            [[NSUserDefaults standardUserDefaults] setValue:serverURLString forKey:kServerAddress];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSURL * url = [NSURL URLWithString:serverURLString];
        NSMutableURLRequest * muRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:20.0];
        [muRequest setHTTPMethod:@"POST"];
        [muRequest setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

        NSString * para = [NSString stringWithFormat:@"common=upfile&name=%@&date=%@&filename=%@&file=%@",
                           name, createdDateString, fileName, [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding]];
        [muRequest setHTTPBody:[para dataUsingEncoding:NSUTF8StringEncoding]];
        FSSendReportHTTP * sendReport = [[FSSendReportHTTP alloc] initWithRequest:muRequest];
        sendReport.target = self;
        [sendReport connect];
    }
}
#pragma mark - HTTP finished call back

- (void)httpFinishedWithSuccess:(BOOL)success ifErrorWithMessage:(NSString *)errorMessage{
    if (success) {
        [NSAlert showErrorMessage:@"上传成功"];
    } else {
        [NSAlert showErrorMessage:errorMessage];
    }
}

#pragma mark - IBAction
- (IBAction)addButtonPressed:(id)sender {
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd cccc"];
    NSString * createdDateString = [self.dateFormatter stringFromDate:self.selectedDate];
    assert(createdDateString);
    NSInteger orderNum = 1;
    NSInteger index = 0;
    for (int i = 0; i < [self.weekReportsMuArray count]; i ++) {
        FSWeekReportObject * obj = [self.weekReportsMuArray objectAtIndex:i];
        if ([obj.createdDate isEqualToString:createdDateString]) {
            orderNum ++;
        }
        if ([createdDateString compare:obj.createdDate] != -1) {
            index ++;
        }

    }
    assert(!isEmptyString(self.lastDayString));
    NSString * createdYear = [self.lastDayString substringToIndex:4];
    
    FSWeekReportObject * weekReportObj = [FSWeekReportObject new];
    [self.weekReportsMuArray insertObject:weekReportObj atIndex:index];
    weekReportObj.weekNum                   = @(_weekNum);
    weekReportObj.createdDate               = createdDateString;
    weekReportObj.orderNum                  = @(orderNum);
    weekReportObj.createdYear               = createdYear;
    weekReportObj.firstDateStringThisWeek   = self.firstDayString;
    weekReportObj.lastDateStringThisWeek    = self.lastDayString;
    if ([self.recentProj isKindOfClass:[FSProjectInfoObject class]]) {
        NSLog(@"select recent project info");
        weekReportObj.projectID = self.recentProj.projectID;
        weekReportObj.projectName = self.recentProj.projectName;
    } else {
        NSLog(@"select null project info");
    }
    if (self.weekSummary != nil) {
        weekReportObj.weekSummaryObject = self.weekSummary;
    } else {
        [self createNewWeekSummary];
    }
    
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.reportTableView insertRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectFade];
    [self.reportTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [self.reportTableView scrollRowToVisible:index];

    NSDictionary * userInfo = @{@"index": @(index)};
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scrollToSpecificRow:) userInfo:userInfo repeats:NO];
}

- (IBAction)removeButtonPressed:(id)sender {
    NSInteger selectedRow = self.reportTableView.selectedRow;
    if (selectedRow >= 0) {
        if (selectedRow < [self.weekReportsMuArray count]) {
            [self.reportTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow]
                                        withAnimation:NSTableViewAnimationEffectFade];
            FSWeekReportObject * weekReport = [self.weekReportsMuArray objectAtIndex:selectedRow];
            if (weekReport.autoIncrementID != nil) {
                [self.logicForMac removeWeekReport:weekReport
                           fromReportsMutableArray:self.weekReportsMuArray];

            } else {
                [self.weekReportsMuArray removeObject:weekReport];
            }

            [self refreshOrder];
            [self.reportTableView reloadData];
        } else {
            [NSAlert showErrorMessage:@"选定行的索引值大于周报总个数，无法删除！"];
        }
        if (selectedRow == 0) {
            [self.reportTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        } else {
            [self.reportTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow - 1] byExtendingSelection:NO];
        }

    }
}

- (IBAction)saveButtonPressed:(id)sender {
    if (![self.saveButton isEnabled]) {
        return;
    }
    //save
    BOOL canSave = [self retrieveDataFromTableViewControlsNeedCheckData:NO];
    if (canSave) {
        [self save];
    }

    [self.saveButton setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(enableSaveButtonAfterSeconds:) userInfo:nil repeats:NO];
    
}

- (IBAction)dateButtonPressed:(id)sender {
    if (self.myDatePicker == nil) {
        self.myDatePicker = [[FSDatePickerViewController alloc] initWithDelegate:self];
    }
    [self.myDatePicker showFromRect:[sender bounds] view:sender edge:NSMaxYEdge];
}

- (IBAction)outputButtonPressed:(id)sender {
    BOOL canSave = [self retrieveDataFromTableViewControlsNeedCheckData:YES];
    if (canSave) {
        [self save];
        self.weekReportExportedURL = [self.logicForMac outputWeekReports:self.weekReportsMuArray];
        if (self.weekReportExportedURL) {
            [self commitToServer];
        }
    }
}

#pragma mark - callback
//timer handler
- (void) enableSaveButtonAfterSeconds:(NSTimer *)timer {
    [self.saveButton setEnabled:YES];
    [timer invalidate];

}

- (void) scrollToSpecificRow:(NSTimer *)timer {
    if (timer.userInfo != nil) {
        NSDictionary * userInfo = timer.userInfo;
        NSInteger index = [[userInfo valueForKey:@"index"] integerValue];
        [self.reportTableView scrollRowToVisible:index];
    }
    [timer invalidate];
}

#pragma mark - Notification
- (void) projectCheckingChanged:(NSNotification *) note {
    if (note.userInfo != nil) {
        NSDictionary * userInfo = note.userInfo;
        NSMutableArray * projects = [NSMutableArray arrayWithObject:[NSNull null]];
        [projects addObjectsFromArray:[userInfo valueForKey:@"projectNameInfos"]];
        self.projectNameInfos = projects;
        [self.reportTableView reloadData];
    }
}

- (void) needSaveCalledNotification:(NSNotification *)note {
    BOOL canSave = [self retrieveDataFromTableViewControlsNeedCheckData:NO];
    if (canSave) {
        [self save];
        [NSApp replyToApplicationShouldTerminate:YES];
    } else {
        [NSApp replyToApplicationShouldTerminate:NO];
    }
}


#pragma mark - DatePickerPopover delegate 

- (void)performActionAfterSelectDate:(NSDate *)date {
    //change date formatter for datebutton title
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * targetDateString = [NSString stringWithFormat:@"日期：%@", [self.dateFormatter stringFromDate:date]];
    [self.dateButton setTitle:targetDateString];
    self.selectedDate = date;
    [self calculateFirstAndLastDayString];
    NSInteger newWeekNum = [self.logicForMac weekNumOfDate:self.selectedDate];
    if (newWeekNum != _weekNum) {
        _weekNum = newWeekNum;
        _needReloadTableViewForLoadDataFromDataBase = YES;
        self.weekSummary = nil;
        //clear recent summary text
        [self reloadSummaryTextView];
        //load week report data and summary from database
        [self loadDataFromDatabase];
    }
}


#pragma mark - NSTableView Delegate and Datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger rows = [self.weekReportsMuArray count];
    return rows;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    FSWeekReportObject * weekReport = [self.weekReportsMuArray objectAtIndex:row];
    NSString * columnIdentifier = tableColumn.identifier;
    NSTableCellView * cellView = [tableView makeViewWithIdentifier:columnIdentifier owner:self];
    if ([columnIdentifier isEqualToString:IdentifierDate]) {
        NSTextField * dateTextField = (NSTextField *)[cellView viewWithTag:ColumnDateTag];
        //change date formatter for column of date
        [dateTextField.cell setTitle:weekReport.createdDate];
    } else if ([columnIdentifier isEqualToString:IdentifierOrder]) {
        NSTextField * orderNumTextField = (NSTextField *)[cellView viewWithTag:ColumnOrderNumTag];
        NSString * orderNumString = [NSString stringWithFormat:@"%@", weekReport.orderNum];
        [orderNumTextField.cell setTitle:orderNumString];
        
        if ([orderNumString isEqualToString:@"1"]) {
            [[tableView rowViewAtRow:row makeIfNecessary:NO] setBackgroundColor:[NSColor colorWithCalibratedRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0f]];
        }
    } else if ([columnIdentifier isEqualToString:IdentifierProject]) {
        NSPopUpButton * popupButton = (NSPopUpButton *)[cellView viewWithTag:ColumnProjectNameTag];
        NSInteger index = 0;
        if (!isEmptyString(weekReport.projectName)) {
            for (int i = 1; i < [self.projectNameInfos count]; i ++) {
                if ([weekReport.projectName isEqualToString:[[self.projectNameInfos objectAtIndex:i] projectName]]) {
                    index = i;
                    break;
                }
            }
        }
        [self clearOldAndAddNewProjectInfos:self.projectNameInfos intoPopUpButton:popupButton];
        NSArray * menuItemArray = [[popupButton menu] itemArray];
        for (NSMenuItem * menuItem in menuItemArray) {
            [menuItem setTarget:self];
            [menuItem setAction:@selector(popupButtonItemDidChange:)];
        }
        [popupButton selectItemAtIndex:index];
        
    } else if ([columnIdentifier isEqualToString:IdentifierTask]) {
        NSTextField * taskContentTextField = (NSTextField *)[cellView viewWithTag:ColumnTaskContentTag];
        [taskContentTextField.cell setTitle:weekReport.taskContent];
    } else if ([columnIdentifier isEqualToString:IdentifierRegular]) {
        NSTextField * normalTimeTextField = (NSTextField *)[cellView viewWithTag:ColumnRegularTimeTag];
        NSString * normalTimeString = [NSString stringWithFormat:@"%.1lf", [weekReport.normalTime doubleValue]];
        [normalTimeTextField.cell setTitle:normalTimeString];
    } else if ([columnIdentifier isEqualToString:IdentifierOverTime]) {
        NSTextField * overTimeTextField = (NSTextField *)[cellView viewWithTag:ColumnOverTimeTag];
        NSString * overTimeString = [NSString stringWithFormat:@"%.1lf", [weekReport.overTime doubleValue]];
        [overTimeTextField.cell setTitle:overTimeString];
    } else if ([columnIdentifier isEqualToString:IdentifierTrafficCost]) {
        NSTextField * carFeeTextField = (NSTextField *)[cellView viewWithTag:ColumnTrafficCostTag];
        NSString * carFeeString = [NSString stringWithFormat:@"%.1lf", [weekReport.carFare doubleValue]];
        [carFeeTextField.cell setTitle:carFeeString];
    } else if ([columnIdentifier isEqualToString:IdentifierFoodCost]) {
        NSComboBox  * mealFeeComboBox = (NSComboBox *)[cellView viewWithTag:ColumnFoodCostTag];
        NSInteger index = 0;
        for (int i = 1; i < [self.mealFeeArray count]; i ++) {
            if ([weekReport.mealFee isEqualToNumber:[self.mealFeeArray objectAtIndex:i]]) {
                index = i;
            }
        }
        [mealFeeComboBox selectItemAtIndex:index];
        [mealFeeComboBox setObjectValue:[self comboBox:mealFeeComboBox objectValueForItemAtIndex:index]];
    } else if ([columnIdentifier isEqualToString:IdentifierWorkTrip]) {
        NSComboBox * bizTripComboBox = (NSComboBox *)[cellView viewWithTag:ColumnWorkTripTag];
        int isBizTrip = [weekReport.isBusinessTrip intValue];
        if (isBizTrip == 1) {
            [bizTripComboBox selectItemAtIndex:1];
        } else {
            [bizTripComboBox selectItemAtIndex:0];
        }
    }
    return cellView;
}

#pragma mark - Custom PopupButton Datasource and Delegate
- (void) clearOldAndAddNewProjectInfos:(NSArray *) projInfos intoPopUpButton:(NSPopUpButton *)popupButton {
    [popupButton removeAllItems];
    assert([projInfos objectAtIndex:0] == [NSNull null]);
    
    for (int i = 0; i < [projInfos count]; i ++) {
        NSString * projName = @"";
        if (i > 0) {
            FSProjectInfoObject * projInfo = [projInfos objectAtIndex:i];
            projName = projInfo.projectName;
        }
        [popupButton addItemWithTitle:projName];
    }
}

- (void)popupButtonItemDidChange:(NSMenuItem *)menuItem {
    NSMenu * menu = [menuItem menu];
    NSInteger index = [menu indexOfItem:menuItem];
    if (index >= 0 && index < [self.projectNameInfos count]) {
        self.recentProj = [self.projectNameInfos objectAtIndex:index];
    }
    [self retrieveDataFromTableViewControlsNeedCheckData:NO];
}

#pragma mark - ComboBox Datasource
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    NSInteger numberOfItems = 0;
    if (aComboBox.tag == ColumnFoodCostTag) {
        numberOfItems = [self.mealFeeArray count];
    }
    return numberOfItems;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (aComboBox.tag == ColumnFoodCostTag) {
        return [self.mealFeeArray objectAtIndex:index];
    }
    return nil;
}

#pragma mark - NSTextField and NSComboBox delegate 
- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [self retrieveDataFromTableViewControlsNeedCheckData:NO];

}

- (void)comboBoxWillDismiss:(NSNotification *)notification {
    [self retrieveDataFromTableViewControlsNeedCheckData:NO];
}



@end
