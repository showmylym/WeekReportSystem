//
//  FSReportInfoCell.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-3.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSReportInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellSequenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellProjectInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellNeedsIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellTaskInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellNormalHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellOvertimeHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellMealFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellTrafficFeeLabel;

+ (FSReportInfoCell *)CellFromNibName:(NSString*)nibName index:(NSInteger)index;

@end
