//
//  FSReportDetailTableViewController.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSReportDetailTableViewController.h"

@interface FSReportDetailTableViewController ()

@end

@implementation FSReportDetailTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.projectID = [NSString new];
        self.ReportDetailTaskInfoText.tag = 5;
        self.ReportDetailNormalHourText.tag = 6;
        self.ReportDetailOvertimeHourText.tag = 7;
        self.ReportDetialMeelFeeText.tag = 8;
        self.ReportDetailTrafficFeeText.tag = 9;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem * finishBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(fillingComplete:)];
    self.navigationItem.rightBarButtonItem = finishBarButtonItem;
    self.navigationItem.title = @"周报编辑";
    
    [self viewDataFromDict];

}

- (void)viewDataFromDict
{
    NSString *projectText = [self.reportInfoFromParentView objectForKey:@"reportDetailProjectName"];
    NSString *needsIdText = [self.reportInfoFromParentView objectForKey:@"reportDetailNeedsId"];
    
    self.ReportDetailDateText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailDate"];
    self.ReportDetailSequenceText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailSequence"];
    self.ReportDetailTaskInfoText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailTaskInfo"];
    self.ReportDetailNormalHourText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailNormalHour"];
    self.ReportDetailOvertimeHourText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailOvertimeHour"];
    self.ReportDetialMeelFeeText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailMeelFee"];
    self.ReportDetailTrafficFeeText.text = [self.reportInfoFromParentView objectForKey:@"reportDetailTrafficFee"];
    
    [self.ReportDetailProjectNameButton setTitle:projectText forState:UIControlStateNormal];
    [self.ReportDetailNeedsIdButton setTitle:needsIdText forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - call back
- (void) fillingComplete:(UIBarButtonItem *)barButtonItem {
    if ([self checkInputValidate] == false) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"请检查是否所有数据已正确填写!\n1.所有项不为空\n2.项目名已选择\n3.常时和加时互斥"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    NSIndexPath *indexPathBack = [self.reportInfoFromParentView objectForKey:@"indexPathFromParentView"];
    NSString * dateText = self.ReportDetailDateText.text;    
    NSString * sequenceText = self.ReportDetailSequenceText.text;
    NSString * projectNameText = self.ReportDetailProjectNameButton.titleLabel.text;
    NSString * needsIdText = self.ReportDetailNeedsIdButton.titleLabel.text;
    NSString * taskInfoText = self.ReportDetailTaskInfoText.text;
    NSString * normalHourText = self.ReportDetailNormalHourText.text;
    NSString * overtimeHourText = self.ReportDetailOvertimeHourText.text;
    NSString * meelFeeText = self.ReportDetialMeelFeeText.text;
    NSString * trafficFeeText = self.ReportDetailTrafficFeeText.text;
    
    NSDictionary * userInfo = @{@"indexPathBack":indexPathBack,
                                @"dateText":dateText,
                                @"SequenceText":sequenceText,
                                @"ProjectNameText":projectNameText,
                                @"NeedsIdText":needsIdText,
                                @"TaskInfoText":taskInfoText,
                                @"NormalHourText":normalHourText,
                                @"OvertimeHourText":overtimeHourText,
                                @"MeelFeeText":meelFeeText,
                                @"TrafficFeeText":trafficFeeText,
                                @"projectID":self.projectID
                                };

    [[NSNotificationCenter defaultCenter] postNotificationName:FillingReportCompleteNotification object:self userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
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
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    UITableViewCell * cell = nil;
    NSInteger row = indexPath.row;
    if (row == 0) {
        self.ReportDetailDateText.borderStyle = UITextBorderStyleNone;
        cell = self.ReportDetailDateCell;
    }
    if (row == 1) {
        self.ReportDetailSequenceText.borderStyle = UITextBorderStyleNone;
        cell = self.ReportDetailSequenceCell;
    }
    if (row == 2) {
        cell = self.ReportDetailProjectNameCell;
    }
    if (row == 3) {
        cell = self.ReportDetailNeedsIdCell;
    }
    if (row == 4) {
        cell = self.ReportDetailTaskInfoCell;
    }
    if (row == 5) {
        cell = self.ReportDetailNormalHourCell;
    }
    if (row == 6) {
        cell = self.ReportDetailOvertimeHourCell;
    }
    if (row == 7) {
        cell = self.ReportDetialMeelFeeCell;
    }
    if (row == 8) {
        cell = self.ReportDetailTrafficFeeCell;
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark - text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *textField1 = (UITextField *)[self.view viewWithTag:textField.tag+1];
    [textField1 becomeFirstResponder];
    
    if (textField1.tag == 0) {
        return NO;
    }
    UITableView * tableView = (UITableView *)self.view;
    CGPoint point = CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y+44);
    [tableView setContentOffset:point animated:YES];
    return YES;
}



- (IBAction)ReportDetailProjectNameButtonPress:(id)sender {    
     FSTempShowTableViewController *tableViewController = [[FSTempShowTableViewController alloc]initWithNibName:@"FSTempShowTableViewController" bundle:nil];
    tableViewController.superViewController = self;
    
    [self presentViewController:tableViewController animated:YES completion:^{}];
}

- (IBAction)ReportDetailNeedsIdButtonPress:(id)sender {
}

- (BOOL)checkInputValidate
{
    NSString * dateText = self.ReportDetailDateText.text;
    NSString * sequenceText = self.ReportDetailSequenceText.text;
    NSString * projectNameText = self.ReportDetailProjectNameButton.titleLabel.text;
//    NSString * needsIdText = self.ReportDetailNeedsIdButton.titleLabel.text;
    NSString * taskInfoText = self.ReportDetailTaskInfoText.text;
    NSString * normalHourText = self.ReportDetailNormalHourText.text;
    NSString * overtimeHourText = self.ReportDetailOvertimeHourText.text;
    NSString * meelFeeText = self.ReportDetialMeelFeeText.text;
    NSString * trafficFeeText = self.ReportDetailTrafficFeeText.text;
    
    BOOL ret = true;
    
    //所有内容内容不为空
    if([dateText            length] == 0 ||
       [sequenceText        length] == 0 ||
       [projectNameText     length] == 0 ||
//       [needsIdText         length] == 0 ||
       [taskInfoText        length] == 0 ||
       [normalHourText      length] == 0 ||
       [overtimeHourText    length] == 0 ||
       [meelFeeText         length] == 0 ||
       [trafficFeeText      length] == 0)
    {
        ret = false;
    }

    //任务内容不为空
    if([taskInfoText length] == 0)
    {
        ret = false;
    }
    
    //常时和加时不可同时为0，且必须有一个为0
    NSInteger normalHour = [normalHourText integerValue];
    NSInteger overTimeHour = [overtimeHourText integerValue];
    if(((normalHour + overTimeHour) == 0) || ((normalHour * overTimeHour) != 0))
    {
        ret = false;
    }

    return ret;
}

@end

NSString * const FillingReportCompleteNotification = @"FillingReportCompleteNotification";


