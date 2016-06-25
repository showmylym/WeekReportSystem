//
//  FSProjectInfoCell.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-19.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSProjectInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *projectIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectNameLabel;

+ (FSProjectInfoCell *)CellFromNibName:(NSString*)nibName index:(NSInteger)index;

@end
