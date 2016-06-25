//
//  FSSettingsViewController.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@property BOOL isEditing;

@end
