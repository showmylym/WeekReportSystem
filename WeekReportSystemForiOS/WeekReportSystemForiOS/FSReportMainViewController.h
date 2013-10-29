//
//  FSReportMainViewController.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSReportInfoCell.h"

@interface FSReportMainViewController : UIViewController
<UIActionSheetDelegate,UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;

@property (weak, nonatomic) IBOutlet UITableView *reportListTableView;

@property (nonatomic) NSInteger currentSection;

- (IBAction)selectDateButtonPress:(id)sender;

@end
