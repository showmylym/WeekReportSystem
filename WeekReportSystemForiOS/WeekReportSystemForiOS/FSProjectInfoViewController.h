//
//  FSProjectInfoViewController.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-4.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSProjectInfoViewController : UIViewController<UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *projectInfoSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *projectInfoTableView;


@property (strong, nonatomic) NSArray *projectInfoArray;
@property (strong, nonatomic) NSArray *projectInfoPredicateArray;

@end
