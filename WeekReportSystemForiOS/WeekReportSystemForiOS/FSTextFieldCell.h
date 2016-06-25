//
//  FSTextFieldCell.h
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-24.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;


+ (FSTextFieldCell *)CellFromNibName:(NSString*)nibName index:(NSInteger)index;

@end
