//
//  FSPersonInfoViewController.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPersonInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *personInfoTableView;

@property BOOL isEditing;
@property NSString *personID;
@property NSString *personName;

@end
