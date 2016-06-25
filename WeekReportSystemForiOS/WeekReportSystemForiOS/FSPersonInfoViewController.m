//
//  FSPersonInfoViewController.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSPersonInfoViewController.h"
#import "FSTextFieldCell.h"

@interface FSPersonInfoViewController ()

@end

@implementation FSPersonInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.personID   = [NSString new];
        self.personName = [NSString new];
        self.isEditing  = NO;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.personID = [userDefaults valueForKey:@"ProfileID"];
        self.personName = [userDefaults valueForKey:@"ProfileName"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPress:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
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
        UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonPress:)];
        self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    }
    else
    {
        UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPress:)];
        self.navigationItem.rightBarButtonItem = editButtonItem;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        FSTextFieldCell *cell = (FSTextFieldCell*)[self.personInfoTableView cellForRowAtIndexPath:indexPath];
        self.personName = cell.textField.text;
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        cell = (FSTextFieldCell*)[self.personInfoTableView cellForRowAtIndexPath:indexPath];
        self.personID = cell.textField.text;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:self.personID forKey:@"ProfileID"];
        [userDefaults setValue:self.personName forKey:@"ProfileName"];
    }
    [self.personInfoTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
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
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        [cell.textField setEnabled:NO];
        cell.backgroundColor = [UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0];
    }
    
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textField.text = self.personName;
    }
    if (indexPath.section == 1) {
        cell.textField.text = self.personID;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *arr = [NSArray arrayWithObjects:@"我的姓名", @"身份证号", nil];
    return arr[section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
