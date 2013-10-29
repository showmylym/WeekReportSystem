//
//  FSProjectInfoCell.m
//  WeekReportSystemForiOS
//
//  Created by forms_chenrui on 13-6-19.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSProjectInfoCell.h"

@implementation FSProjectInfoCell

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

+ (FSProjectInfoCell *)CellFromNibName:(NSString*)nibName index:(NSInteger)index{
    FSProjectInfoCell * cell = (FSProjectInfoCell *)[[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:index];
    return cell;
}

@end
