//
//  FSMyProjectView.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern NSString * const ProjectCheckingChangedNotification;

@interface FSMyProjectView : NSView
<NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSSearchField * keyWordSearchField;

@property (weak) IBOutlet NSTableView * projectInfoTableView;

- (IBAction)inputButtonPressed:(id)sender;
- (IBAction)checkButtonPressed:(id)sender;

@end
