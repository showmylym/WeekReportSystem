//
//  FSReportDetailTableViewController.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTempShowTableViewController.h"

extern NSString * const FillingReportCompleteNotification;

@interface FSReportDetailTableViewController : UITableViewController<UIActionSheetDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailDateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailSequenceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailProjectNameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailNeedsIdCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailTaskInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailNormalHourCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailOvertimeHourCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetialMeelFeeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ReportDetailTrafficFeeCell;

@property (weak, nonatomic) IBOutlet UITextField *ReportDetailDateText;
@property (weak, nonatomic) IBOutlet UITextField *ReportDetailSequenceText;
@property (weak, nonatomic) IBOutlet UIButton *ReportDetailProjectNameButton;
@property (weak, nonatomic) IBOutlet UIButton *ReportDetailNeedsIdButton;
@property (weak, nonatomic) IBOutlet UITextField *ReportDetailTaskInfoText;
@property (weak, nonatomic) IBOutlet UITextField *ReportDetailNormalHourText;
@property (weak, nonatomic) IBOutlet UITextField *ReportDetailOvertimeHourText;
@property (weak, nonatomic) IBOutlet UITextField *ReportDetialMeelFeeText;
@property (weak, nonatomic) IBOutlet UITextField *ReportDetailTrafficFeeText;

@property NSString * projectID;
#pragma mark -- custom define propertys
@property (strong, nonatomic) NSMutableDictionary * reportInfoFromParentView;

- (IBAction)ReportDetailProjectNameButtonPress:(id)sender;
- (IBAction)ReportDetailNeedsIdButtonPress:(id)sender;

@end
