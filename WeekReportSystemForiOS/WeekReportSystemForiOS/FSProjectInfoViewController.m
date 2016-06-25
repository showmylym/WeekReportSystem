//
//  FSProjectInfoViewController.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSProjectInfoViewController.h"
#import "FSProjectInfoCell.h"
#import <FSProjectInfoObject.h>
#import <FSMainLogic.h>

@interface FSProjectInfoViewController ()
@property BOOL isAdding;
@end

@implementation FSProjectInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        FSMainLogic *mainLogicObject = [FSMainLogic new];
        NSArray *array = [mainLogicObject selectAllProjectsInfos];
        self.projectInfoArray = [NSArray arrayWithArray:array];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isChecked = 1"];
        self.projectInfoPredicateArray = [self.projectInfoArray filteredArrayUsingPredicate:predicate];
        
        self.isAdding = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem * importBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:UIBarButtonItemStylePlain target:self action:@selector(importButtonPress:)];
    self.navigationItem.leftBarButtonItem = importBarButtonItem;
    
//    importBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(showModeButtonPress:)];
//    self.navigationItem.rightBarButtonItem = importBarButtonItem;
    
    UIBarButtonItem * addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showModeButtonPress:)];
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [self.projectInfoTableView reloadData];
}

- (void)reloadDataWithSearchKey
{
    NSString * keyWord = self.projectInfoSearchBar.text;
    
    if (!self.isAdding) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isChecked = 1"];
        self.projectInfoPredicateArray = [self.projectInfoArray filteredArrayUsingPredicate:predicate];
        
        if (isEmptyString(keyWord))
        {
            ;
        }
        else
        {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"projectID contains[CD] %@ or projectName contains[CD] %@", keyWord, keyWord];
            self.projectInfoPredicateArray = [self.projectInfoPredicateArray filteredArrayUsingPredicate:predicate];
        }
    }
    else
    {
        if (isEmptyString(keyWord))
        {
            self.projectInfoPredicateArray = self.projectInfoArray;
        }
        else
        {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"projectID contains[CD] %@ or projectName contains[CD] %@", keyWord, keyWord];
            self.projectInfoPredicateArray = [self.projectInfoArray filteredArrayUsingPredicate:predicate];
        }
    }
    
    [self.projectInfoTableView reloadData];
}

//点击导航右侧显示按钮
- (void) showModeButtonPress:(id)sender
{
    self.isAdding = !self.isAdding;
    if (self.isAdding)
    {
        UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(showModeButtonPress:)];
        self.navigationItem.rightBarButtonItem = doneBarButtonItem;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isChecked = 0"];
        self.projectInfoPredicateArray = [self.projectInfoArray filteredArrayUsingPredicate:predicate];
    }
    else
    {
        UIBarButtonItem * addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showModeButtonPress:)];
        self.navigationItem.rightBarButtonItem = addBarButtonItem;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isChecked = 1"];
        self.projectInfoPredicateArray = [self.projectInfoArray filteredArrayUsingPredicate:predicate];
        
        [self.projectInfoSearchBar resignFirstResponder];
    }
    
    self.projectInfoSearchBar.text = @"";
    [self.projectInfoTableView reloadData];
}

//点击导航左侧导入按钮
- (void) importButtonPress:(id)sender {
    NSString * projectInfoXMLPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"project.xml"];
    
    FSMainLogic *mainLogicObject = [FSMainLogic new];
    NSURL *fileURL = [NSURL fileURLWithPath:projectInfoXMLPath isDirectory:NO];
    //保存已选取的项目
    NSArray *checkedProjectsArray = [mainLogicObject selectProjectsInfoIsChecked];
    
    NSArray *array = [NSArray new];
    if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
        array = [mainLogicObject projectInfosParsedByXMLFile:fileURL];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"无法获取到指定的项目导入文件，请联系管理员。"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    if ([self.projectInfoArray count] != 0 && ![mainLogicObject clearAllProjectsInfoInDatabase]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"导入前清空原有项目失败！"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    };
    [mainLogicObject saveInputProjectInfos:array];
    //更新分配的id并存储
    [mainLogicObject retrieveIDFromDatabaseByProjectsInfo:checkedProjectsArray];
    for (FSProjectInfoObject *objc in checkedProjectsArray) {
        [mainLogicObject saveProjectInfo:objc];
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:@"导入成功！"
                                                delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    self.projectInfoArray = [mainLogicObject selectAllProjectsInfos];
    self.projectInfoPredicateArray = [mainLogicObject selectProjectsInfoIsChecked];
    //导入后显示已选的项目
    self.isAdding = NO;
    self.navigationItem.rightBarButtonItem.title = @"添加";
    self.projectInfoSearchBar.text = @"";
    [self.projectInfoTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.projectInfoPredicateArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"FSProjectInfoCellID";
    FSProjectInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [FSProjectInfoCell CellFromNibName:@"FSCells" index:2];
    }
    
    FSProjectInfoObject *objc = [self.projectInfoPredicateArray objectAtIndex:indexPath.row];
    cell.projectIDLabel.text = objc.projectID;
    cell.projectNameLabel.text = objc.projectName;
    
    //设置单元格复选
    cell.accessoryType = objc.isChecked.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSProjectInfoObject *objc = [self.projectInfoPredicateArray objectAtIndex:indexPath.row];
    NSNumber *checked = objc.isChecked;
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (!checked.boolValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    objc.isChecked = [NSNumber numberWithBool:!checked.boolValue];
    
    FSMainLogic *mainLogicObject = [FSMainLogic new];
    [mainLogicObject saveProjectInfo:objc];
    NSArray *array = [NSArray arrayWithObject:objc];
    [mainLogicObject retrieveIDFromDatabaseByProjectsInfo:array];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - searchBar delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self reloadDataWithSearchKey];
    [self.projectInfoSearchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{      
    [self reloadDataWithSearchKey];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.projectInfoSearchBar resignFirstResponder];
}

@end
