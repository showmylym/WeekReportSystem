//
//  FSDatePickerViewController.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-6-3.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//protocol
@protocol DatePickerPopoverDelegate <NSObject>

- (void) performActionAfterSelectDate:(NSDate *)date;

@end

//view controller
@interface FSDatePickerViewController : NSViewController
<NSPopoverDelegate>

@property (weak) id<DatePickerPopoverDelegate> delegate;

@property (weak) IBOutlet NSDatePicker * datePicker;

- (void) modifyDelegate:(id<DatePickerPopoverDelegate>)delegate;
//show popover
- (void) showFromRect:(NSRect)positioningRect view:(NSView *)positioningRect edge:(NSRectEdge)preferredEdge;
//init method
- (id) initWithDelegate:(id<DatePickerPopoverDelegate>)delegate;
//IBAction
- (IBAction)confirmButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
