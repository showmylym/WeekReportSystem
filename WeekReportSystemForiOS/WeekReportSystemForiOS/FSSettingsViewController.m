//
//  FSSettingsViewController.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSSettingsViewController.h"
#import "FSTextFieldCell.h"

@interface FSSettingsViewController ()

@end

@implementation FSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPress:)];
        self.navigationItem.rightBarButtonItem = editButtonItem;
        
        self.isEditing = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editButtonPress:(id)sender
{
    self.isEditing = !self.isEditing;
    if (self.isEditing)
    {
        self.navigationItem.rightBarButtonItem.title = @"完成";
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"编辑";
    }
    [self.settingTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FSTextFieldCell* cell = [FSTextFieldCell CellFromNibName:@"FSCells" index:3];
    if (self.isEditing) {
        [cell.textField setEnabled:YES];
    }
    else
    {
        [cell.textField setEnabled:NO];
        
        cell.backgroundColor = [UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0];
    }
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *arr = [NSArray arrayWithObjects:@"周报部门名称", @"周报接受服务器地址", @"周报接受服务器端口", @"是否开启需求管理", @"FTP地址", @"FTP端口", @"FTP用户", @"FTP密码", nil];
    return arr[section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
