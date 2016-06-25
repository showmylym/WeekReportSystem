//
//  FSTempShowTableViewController.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-5.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSReportDetailTableViewController;

@interface FSTempShowTableViewController : UIViewController

@property (weak) IBOutlet UITableView * defaultTableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *titleBar;


@property (weak) FSReportDetailTableViewController * superViewController;
@property (strong, nonatomic) NSArray *projectInfoArray;
           
@end
