//
//  FSReportMainViewController.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSReportMainViewController.h"
#import "FSReportDetailTableViewController.h"
#import <FSWeekReportObject.h>
#import <FSMainLogic.h>


@interface FSReportMainViewController ()
@property (strong, nonatomic) NSMutableArray * reportObjectsInWeekTotal;
@property (strong, nonatomic) NSMutableArray * reportObjectsInMon;
@property (strong, nonatomic) NSMutableArray * reportObjectsInTus;
@property (strong, nonatomic) NSMutableArray * reportObjectsInWed;
@property (strong, nonatomic) NSMutableArray * reportObjectsInThu;
@property (strong, nonatomic) NSMutableArray * reportObjectsInFri;
@property (strong, nonatomic) NSMutableArray * reportObjectsInSat;
@property (strong, nonatomic) NSMutableArray * reportObjectsInSun;

@property (strong, nonatomic) FSWeekSummaryObject * weekSummaryObject;
@end

@implementation FSReportMainViewController

#define DATE_FORMAT_COMMON @"yyyy-MM-dd cccc"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //arrays init
        self.reportObjectsInWeekTotal = [NSMutableArray new];
        self.reportObjectsInMon = [NSMutableArray new];
        self.reportObjectsInTus = [NSMutableArray new];
        self.reportObjectsInWed = [NSMutableArray new];
        self.reportObjectsInThu = [NSMutableArray new];
        self.reportObjectsInFri = [NSMutableArray new];
        self.reportObjectsInSat = [NSMutableArray new];
        self.reportObjectsInSun = [NSMutableArray new];
        
        self.weekSummaryObject = [FSWeekSummaryObject new];
        //right nvaigation button set
        UIBarButtonItem * exportButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"导出" style:UIBarButtonItemStylePlain target:self action:@selector(exportButtonPress:)];
        self.navigationItem.rightBarButtonItem = exportButtonItem;
        
//        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemEdit,@selector(ABC));
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.datePickerButton setTitle:[self getStringFromFormatDate:[NSDate date] dataFormat:DATE_FORMAT_COMMON] forState:UIControlStateNormal];
    [self reloadReportInfoByAddNavigateDate:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportFillingComplete:) name:FillingReportCompleteNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button pressed event

-(void)exportButtonPress:(id)sender
{
    //检查每日常时是否为8小时
    for (int section = 0; section < 7; section++) {
        int totalHourOneDay = 0;
        int rowsOfSection = [self arraysCountOfSection:section];
        if (rowsOfSection == 0) {
            continue;
        }
        for (int row = 0; row < rowsOfSection; row++) {
            FSWeekReportObject *objc = [self arraysObjectAtIndex:section indexRow:row];
            totalHourOneDay += objc.normalTime.integerValue;
        }
        if (totalHourOneDay != 8) {
            FSWeekReportObject *objc = [self arraysObjectAtIndex:section indexRow:0];            
            NSString *showMessage = [NSString stringWithFormat:@"(%@)常时不足8小时,请修改后重试",objc.createdDate];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                         message:showMessage
                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
    }
    
    //导出周报
    FSMainLogic *mainLogicObject = [FSMainLogic new];
    if ([mainLogicObject outputWeekReports:[self subArraysToArray]]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"导出成功！"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"导出失败！"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void)reloadReportInfoByAddNavigateDate:(NSInteger)addValue
{
    //使用DATE_FORMAT_COMMON格式转化NSString到NSDate,转化后数据异常,系统函数解析出错,暂未找到解决方法
    //因此，此处截取导航时间字符串前十位进行转换
    NSString *tmpText = self.datePickerButton.titleLabel.text;
    tmpText = [tmpText substringToIndex:10];
    NSDate * navigateDate = [self getDateFromFormattingString:tmpText dataFormat:@"yyyy-MM-dd"];
    NSTimeInterval timeInterval = addValue*24*60*60;
    NSDate *date = [navigateDate dateByAddingTimeInterval:timeInterval];
    
    //获取选中日期对应的该周的周报信息
    NSString *startDate = [self getStringFromFormatDate:[self getDateForDay:date day:1] dataFormat:DATE_FORMAT_COMMON];
    NSString *endDate = [self getStringFromFormatDate:[self getDateForDay:date day:7] dataFormat:DATE_FORMAT_COMMON];
    FSMainLogic *mainLogicObject = [FSMainLogic new];
    NSArray *reportDataArray = [mainLogicObject selectAllWeekReportFromDateString:startDate toDateString:endDate];
    
    [self.datePickerButton setTitle:startDate forState:UIControlStateNormal];
    [self ArrayToSubArrays:reportDataArray];
    [self.reportListTableView reloadData];
}

- (IBAction)lastWeekButtonPress:(id)sender {
    [self reloadReportInfoByAddNavigateDate:-7];
}

- (IBAction)nextWeekButtonPress:(id)sender {
    [self reloadReportInfoByAddNavigateDate:7];
}

- (IBAction)selectDateButtonPress:(id)sender
{
    NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)?@"\n\n\n\n\n\n\n\n\n":@"\n\n\n\n\n\n\n\n\n\n\n\n";
    //    [self.reportListTableView setEditing:YES];
    
    //Build the action sheet and present it
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"set", nil];
    [actionSheet showInView:self.view.window];
    
    //Create and add the date picker
    UIDatePicker *datePicker = [UIDatePicker new];
    NSLocale * local = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    [datePicker setLocale:local];
    datePicker.tag = 101;
    datePicker.datePickerMode = UIDatePickerModeDate;
    [actionSheet addSubview:datePicker];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
    NSDate *date = datePicker.date;
    //Recover the picker
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self.datePickerButton setTitle:[self getStringFromFormatDate:date dataFormat:DATE_FORMAT_COMMON] forState:UIControlStateNormal];
    }
    
    //获取选中日期对应的该周的周报信息
    NSString *startDate = [self getStringFromFormatDate:[self getDateForDay:date day:1] dataFormat:DATE_FORMAT_COMMON];
    NSString *endDate = [self getStringFromFormatDate:[self getDateForDay:date day:7] dataFormat:DATE_FORMAT_COMMON];
    FSMainLogic *mainLogicObject = [FSMainLogic new];
    NSArray *reportDataArray = [mainLogicObject selectAllWeekReportFromDateString:startDate toDateString:endDate];
    
    [self ArrayToSubArrays:reportDataArray];
    [self.reportListTableView reloadData];
}

//在按钮所在的section下，添加一条周报
- (void)addItem:(id) sender
{
    UIButton * addButton = (UIButton *)sender;
    self.currentSection = addButton.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.reportListTableView numberOfRowsInSection:self.currentSection] inSection:self.currentSection];
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:indexPath, nil];
    
    //获取当前新增cell对应的日期
    NSString *dateText = nil;
    //使用DATE_FORMAT_COMMON格式转化NSString到NSDate,转化后数据异常,系统函数解析出错,暂未找到解决方法
    //因此，此处截取导航时间字符串前十位进行转换
    NSString *tmpText = self.datePickerButton.titleLabel.text;
    tmpText = [tmpText substringToIndex:10];
    NSDate * navigateDate = [self getDateFromFormattingString:tmpText dataFormat:@"yyyy-MM-dd"];
    NSDate *cellDate = [self getDateForDay:navigateDate day:self.currentSection+1];
    dateText = [self getStringFromFormatDate:cellDate dataFormat:DATE_FORMAT_COMMON];
    NSString *weekNumString = [self getStringFromFormatDate:cellDate dataFormat:@"ww"];
    
    FSWeekReportObject *item = [[FSWeekReportObject alloc] init];
    //初始化item
    item.projectName    = @"";
    item.requirementID  = @" ";//need a value which length > 0
    item.taskContent    = @"";
    item.normalTime     = @0;
    item.overTime       = @0;
    item.mealFee        = @0;
    item.carFare        = @0;
    //为item日期赋值
    item.createdDate = dateText;
    FSMainLogic *mainLogicObject = [FSMainLogic new];
    item.weekNum = [NSNumber numberWithInteger:[mainLogicObject weekNumOfDate:navigateDate]];
    //为item序号赋值
    item.orderNum = [NSNumber numberWithInteger:indexPath.row+1];
    [self arraysAddItem:item index:indexPath.section];
    
    //插入行
    [self.reportListTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    //为新增cell展示日期
    FSReportInfoCell* cell = (FSReportInfoCell*)[self.reportListTableView cellForRowAtIndexPath:indexPath];
    cell.cellDateLabel.text = dateText;
    //为新增cell展示序号
    cell.cellSequenceLabel.text = [NSString stringWithFormat:@"%d.",indexPath.row+1];
    
    //将该条周报数据存储到数据库
    NSArray *array = [NSArray arrayWithObject:item];
    [mainLogicObject saveWeekReports:array];
    [mainLogicObject retrieveIDFromDatabaseByWeekReports:array];
}

#pragma mark - Notification call back
- (void) reportFillingComplete:(NSNotification *) note {
    NSDictionary * userInfo = note.userInfo;
    if (userInfo) {
        FSReportInfoCell* cell = (FSReportInfoCell*)[self.reportListTableView cellForRowAtIndexPath:[userInfo objectForKey:@"indexPathBack"]];
        cell.cellSequenceLabel.text     = [userInfo objectForKey:@"SequenceText"];
        cell.cellProjectInfoLabel.text  = [userInfo objectForKey:@"ProjectNameText"];
        cell.cellNeedsIdLabel.text      = [userInfo objectForKey:@"NeedsIdText"];
        cell.cellTaskInfoLabel.text     = [userInfo objectForKey:@"TaskInfoText"];
        cell.cellNormalHourLabel.text   = [userInfo objectForKey:@"NormalHourText"];
        cell.cellOvertimeHourLabel.text = [userInfo objectForKey:@"OvertimeHourText"];
        cell.cellMealFeeLabel.text      = [userInfo objectForKey:@"MeelFeeText"];
        cell.cellTrafficFeeLabel.text   = [userInfo objectForKey:@"TrafficFeeText"];
        
        NSIndexPath *indexPath = [userInfo objectForKey:@"indexPathBack"];
        FSWeekReportObject *cellInfo = [self arraysObjectAtIndex:indexPath.section indexRow:indexPath.row];
        [self getTableCell:cell fillingData:cellInfo];
        cellInfo.projectID = [userInfo objectForKey:@"projectID"];

        //将该条周报数据存储到数据库
        NSArray *array = [NSArray arrayWithObject:cellInfo];
        FSMainLogic *mainLogicObject = [FSMainLogic new];
        [mainLogicObject saveWeekReports:array];
        [mainLogicObject retrieveIDFromDatabaseByWeekReports:array];
        
    }
}

#pragma mark - date operate

- (NSString *) getStringFromFormatDate:(NSDate *)date dataFormat:(NSString*)dataFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale * local = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    [formatter setLocale:local];
    formatter.dateFormat = dataFormat;
    return [formatter stringFromDate:date];
}

- (NSDate *) getDateFromFormattingString:(NSString *)dateString dataFormat:(NSString*)dataFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale * local = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    [formatter setLocale:local];
    formatter.dateFormat = dataFormat;
    return [formatter dateFromString:dateString];
}

//获取日期对应的那一周某一天的日期
//day=1表示周一，day=7表示周日，其他类推
- (NSDate *) getDateForDay:(NSDate *)date day:(NSInteger)day
{
    NSString *weekInString = [self getStringFromFormatDate:date dataFormat:@"c"];
    NSInteger weekInNumber = [weekInString integerValue];
    weekInNumber--;
    if (weekInNumber == 0) {
        weekInNumber = 7;
    }
    NSTimeInterval timeInterval = (day - 1 - (weekInNumber - 1))*24*60*60;
    NSDate *dateForday = [date dateByAddingTimeInterval:timeInterval];
    
    return dateForday;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self arraysCountOfSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *arr = [NSArray arrayWithObjects:@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期天", nil];
        
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    
    UILabel * dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 10.0f, 80.0f, 30.0f)];
    dayLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:dayLabel];
    if (section < [arr count]) {
        dayLabel.text = [arr objectAtIndex:section];
    }
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.tag = section;
    [addButton addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
//    addButton.frame = CGRectMake(264.0f, 7.0f, 50.0f, 30.0f);
    addButton.frame = CGRectMake(0.0f, 10.0f, 50.0f, 30.0f);
    [view addSubview:addButton];
    return view;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *indexPathArray = [NSArray arrayWithObjects:indexPath, nil];
    
    FSWeekReportObject *objc = [self arraysObjectAtIndex:indexPath.section indexRow:indexPath.row];
    [self arraysRemoveItem:objc indexSection:indexPath.section indexRow:indexPath.row];

    //如果存在标识符，将该条数据从数据库中移除
    if (objc.autoIncrementID != nil) {
        FSMainLogic *mainLogicObject = [FSMainLogic new];
        //移除
        [mainLogicObject removeWeekReport:objc fromReportsMutableArray:nil];
    }
    [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    //更新该section下cell的序号
    NSInteger startUpdateNumber = indexPath.row;
    NSInteger endUpdateNumber = [self arraysCountOfSection:indexPath.section] - 1;
    for (; startUpdateNumber <= endUpdateNumber; startUpdateNumber++) {
        FSMainLogic *mainLogicObject = [FSMainLogic new];
        objc = [self arraysObjectAtIndex:indexPath.section indexRow:startUpdateNumber];
        objc.orderNum = [NSNumber numberWithInteger:startUpdateNumber+1];
        NSArray *array = [NSArray arrayWithObject:objc];
        [mainLogicObject saveWeekReports:array];
    }
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"FSReportInfoCellID";
    FSReportInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [FSReportInfoCell CellFromNibName:@"FSCells" index:0];
    }
    
    // Configure the cell...
    FSWeekReportObject *cellInfo = [self arraysObjectAtIndex:indexPath.section indexRow:indexPath.row];
    cellInfo.firstDateStringThisWeek = [cellInfo.createdDate substringToIndex:10];
    cellInfo.createdYear = [cellInfo.createdDate substringToIndex:4];
    cellInfo.weekSummaryObject = self.weekSummaryObject;
    [self setTableCell:cell fillingData:cellInfo];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *arr = [NSArray arrayWithObjects:@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期天", nil];
    return arr[section];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    FSReportDetailTableViewController * vc = [[FSReportDetailTableViewController alloc] initWithNibName:@"FSReportDetailTableViewController" bundle:nil];
    
    FSReportInfoCell* cell = (FSReportInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSIndexPath *indexPathBack = indexPath;
    NSString * dateText = cell.cellDateLabel.text;
    NSString * sequenceText = cell.cellSequenceLabel.text;
    NSString * projectNameText = cell.cellProjectInfoLabel.text;
    NSString * needsIdText = cell.cellNeedsIdLabel.text;
    NSString * taskInfoText = cell.cellTaskInfoLabel.text;
    NSString * normalHourText = cell.cellNormalHourLabel.text;
    NSString * overtimeHourText = cell.cellOvertimeHourLabel.text;
    NSString * meelFeeText = cell.cellMealFeeLabel.text;
    NSString * trafficFeeText = cell.cellTrafficFeeLabel.text;
    NSDictionary * userInfo = @{@"indexPathFromParentView":indexPathBack,
                                @"reportDetailDate":dateText,
                                @"reportDetailSequence":sequenceText,
                                @"reportDetailProjectName":projectNameText,
                                @"reportDetailNeedsId":needsIdText,
                                @"reportDetailTaskInfo":taskInfoText,
                                @"reportDetailNormalHour":normalHourText,
                                @"reportDetailOvertimeHour":overtimeHourText,
                                @"reportDetailMeelFee":meelFeeText,
                                @"reportDetailTrafficFee":trafficFeeText
                                };
    if (vc.reportInfoFromParentView == nil) {
        vc.reportInfoFromParentView = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    [vc.reportInfoFromParentView setDictionary:userInfo];
    
    FSWeekReportObject *cellInfo = [self arraysObjectAtIndex:indexPath.section indexRow:indexPath.row];
    vc.projectID = cellInfo.projectID;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //设置导航日期为当前点击的cell日期
    FSWeekReportObject *cellInfo = [self arraysObjectAtIndex:indexPath.section indexRow:indexPath.row];
    [self.datePickerButton setTitle:cellInfo.createdDate forState:UIControlStateNormal];
}

#pragma mark - filling cell of tableview
- (void)setTableCell:(FSReportInfoCell *)cell fillingData:(FSWeekReportObject *)cellInfo
{
    cell.cellDateLabel.text         = cellInfo.createdDate;    
    cell.cellSequenceLabel.text     = [[cellInfo.orderNum stringValue] stringByAppendingString:@"."];
    cell.cellProjectInfoLabel.text  = cellInfo.projectName;
    cell.cellNeedsIdLabel.text      = cellInfo.requirementID;
    cell.cellTaskInfoLabel.text     = cellInfo.taskContent;
    cell.cellNormalHourLabel.text   = [cellInfo.normalTime stringValue];
    cell.cellOvertimeHourLabel.text = [cellInfo.overTime stringValue];
    cell.cellMealFeeLabel.text      = [cellInfo.mealFee stringValue];
    cell.cellTrafficFeeLabel.text   = [cellInfo.carFare stringValue];
}

- (void)getTableCell:(FSReportInfoCell *)cell fillingData:(FSWeekReportObject *)cellInfo
{
    cellInfo.createdDate    = cell.cellDateLabel.text;
    cellInfo.requirementID  = cell.cellSequenceLabel.text;
    cellInfo.projectName    = cell.cellProjectInfoLabel.text;
    cellInfo.requirementID  = cell.cellNeedsIdLabel.text;
    cellInfo.taskContent    = cell.cellTaskInfoLabel.text;
    cellInfo.normalTime     = [NSNumber numberWithFloat:[cell.cellNormalHourLabel.text floatValue]];
    cellInfo.overTime       = [NSNumber numberWithFloat:[cell.cellOvertimeHourLabel.text floatValue]];
    cellInfo.mealFee        = [NSNumber numberWithFloat:[cell.cellMealFeeLabel.text floatValue]];
    cellInfo.carFare        = [NSNumber numberWithFloat:[cell.cellTrafficFeeLabel.text floatValue]];
}



#pragma mark - report data arrays operate

- (void)arraysAddItem:(id)item index:(NSInteger)index
{
    switch (index) {
        case 0:
            [self.reportObjectsInMon addObject:item];
            break;
        case 1:
            [self.reportObjectsInTus addObject:item];
            break;
        case 2:
            [self.reportObjectsInWed addObject:item];
            break;
        case 3:
            [self.reportObjectsInThu addObject:item];
            break;
        case 4:
            [self.reportObjectsInFri addObject:item];
            break;
        case 5:
            [self.reportObjectsInSat addObject:item];
            break;
        case 6:
            [self.reportObjectsInSun addObject:item];
            break;
            
        default:
            break;
    }
}

- (void)arraysRemoveItem:(id)item indexSection:(NSInteger)indexSection indexRow:(NSInteger)indexRow
{
    switch (indexSection) {
        case 0:
            [self.reportObjectsInMon removeObjectAtIndex:indexRow];
            break;
        case 1:
            [self.reportObjectsInTus removeObjectAtIndex:indexRow];
            break;
        case 2:
            [self.reportObjectsInWed removeObjectAtIndex:indexRow];
            break;
        case 3:
            [self.reportObjectsInThu removeObjectAtIndex:indexRow];
            break;
        case 4:
            [self.reportObjectsInFri removeObjectAtIndex:indexRow];
            break;
        case 5:
            [self.reportObjectsInSat removeObjectAtIndex:indexRow];
            break;
        case 6:
            [self.reportObjectsInSun removeObjectAtIndex:indexRow];
            break;
            
        default:
            break;
    }
}

- (id)arraysObjectAtIndex:(NSInteger)indexSection indexRow:(NSInteger)indexRow
{
    id item = nil;
    switch (indexSection) {
        case 0:
            item = [self.reportObjectsInMon objectAtIndex:indexRow];
            break;
        case 1:
            item = [self.reportObjectsInTus objectAtIndex:indexRow];
            break;
        case 2:
            item = [self.reportObjectsInWed objectAtIndex:indexRow];
            break;
        case 3:
            item = [self.reportObjectsInThu objectAtIndex:indexRow];
            break;
        case 4:
            item = [self.reportObjectsInFri objectAtIndex:indexRow];
            break;
        case 5:
            item = [self.reportObjectsInSat objectAtIndex:indexRow];
            break;
        case 6:
            item = [self.reportObjectsInSun objectAtIndex:indexRow];
            break;
            
        default:
            break;
    }
    return item;
}

- (NSInteger)arraysCountOfSection:(NSInteger)indexSection
{
    NSInteger item = 0;
    switch (indexSection) {
        case 0:
            item = [self.reportObjectsInMon count];
            break;
        case 1:
            item = [self.reportObjectsInTus count];
            break;
        case 2:
            item = [self.reportObjectsInWed count];
            break;
        case 3:
            item = [self.reportObjectsInThu count];
            break;
        case 4:
            item = [self.reportObjectsInFri count];
            break;
        case 5:
            item = [self.reportObjectsInSat count];
            break;
        case 6:
            item = [self.reportObjectsInSun count];
            break;
            
        default:
            break;
    }
    return item;
}


#pragma mark - report data sub-arrays and one-week-data array operate
- (NSArray*)subArraysToArray
{
    NSArray* array = [NSArray new];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInMon];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInTus];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInWed];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInThu];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInFri];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInSat];
    array  = [array arrayByAddingObjectsFromArray:self.reportObjectsInSun];
    return array;
}

- (void)ArrayToSubArrays:(NSArray *)array
{
    [self.reportObjectsInMon removeAllObjects];
    [self.reportObjectsInTus removeAllObjects];
    [self.reportObjectsInWed removeAllObjects];
    [self.reportObjectsInThu removeAllObjects];
    [self.reportObjectsInFri removeAllObjects];
    [self.reportObjectsInSat removeAllObjects];
    [self.reportObjectsInSun removeAllObjects];
    
    int count = [array count];
    for (int i = 0; i < count; i++) {
        FSWeekReportObject *objc = array[i];
        NSDate *date = [self getDateFromFormattingString:objc.createdDate dataFormat:DATE_FORMAT_COMMON];
        NSString *weekInString = [self getStringFromFormatDate:date dataFormat:@"c"];        
        NSInteger weekInNumber = [weekInString integerValue];
        weekInNumber--;        
        if (weekInNumber == 0) {
            weekInNumber = 7;
        }
        switch (weekInNumber) {
            case 1:
                [self.reportObjectsInMon addObject:objc];
                break;
            case 2:
                [self.reportObjectsInTus addObject:objc];
                break;
            case 3:
                [self.reportObjectsInWed addObject:objc];
                break;
            case 4:
                [self.reportObjectsInThu addObject:objc];
                break;
            case 5:
                [self.reportObjectsInFri addObject:objc];
                break;
            case 6:
                [self.reportObjectsInSat addObject:objc];
                break;
            case 7:
                [self.reportObjectsInSun addObject:objc];
                break;
                
            default:
                break;
        }
    }
}

@end
