//
//  FSTextFieldCell.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-24.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSTextFieldCell.h"

@implementation FSTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FSTextFieldCell *)CellFromNibName:(NSString*)nibName index:(NSInteger)index{
    FSTextFieldCell * cell = (FSTextFieldCell *)[[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:index];
    return cell;
}

@end
