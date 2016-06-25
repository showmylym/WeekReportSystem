//
//  FSMyWeekReportView.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSDatePickerViewController.h"
#import <FSSendReportHTTP.h>

extern NSString * const ProjectCheckingChangedNotification;


//class definition
@interface FSMyWeekReportView : NSView
<NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate,
DatePickerPopoverDelegate, NSControlTextEditingDelegate, FSHTTPResultCallBack>

@property (weak) IBOutlet NSButton * addButton;
@property (weak) IBOutlet NSButton * saveButton;
@property (weak) IBOutlet NSButton * dateButton;
@property (weak) IBOutlet NSButton * outputButton;
@property (weak) IBOutlet NSTableView *reportTableView;
@property (assign) IBOutlet NSTextView * thisSummaryTextView;
@property (assign) IBOutlet NSTextView * nextPlanTextView;
@property (weak) IBOutlet NSTextField * normalTimeLabel;

- (IBAction)addButtonPressed:(id)sender;
//- (IBAction)moveUpOneOrder:(id)sender;
//- (IBAction)moveDownOneOrder:(id)sender;
- (IBAction)removeButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)dateButtonPressed:(id)sender;
- (IBAction)outputButtonPressed:(id)sender;
@end

