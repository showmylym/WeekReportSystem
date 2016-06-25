//
//  FSDatePickerViewController.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-6-3.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSDatePickerViewController.h"

@interface FSDatePickerViewController ()
{
    BOOL _isClosePopoverByConfirmButton;
}
@property (strong) NSPopover * popover;
@property (strong) NSDate * lastDate;
@end

@implementation FSDatePickerViewController

- (void)loadView {
    [super loadView];
    self.datePicker.dateValue = self.lastDate = [NSDate date];
    _isClosePopoverByConfirmButton = NO;


}

- (id) initWithDelegate:(id<DatePickerPopoverDelegate>)delegate {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)modifyDelegate:(id<DatePickerPopoverDelegate>)delegate {
    self.delegate = delegate;
}

- (void)showFromRect:(NSRect)positioningRect view:(NSView *)positioningView edge:(NSRectEdge)preferredEdge {
    if (self.popover == nil) {
        self.popover = [NSPopover new];
        self.popover.delegate = self;
        self.popover.appearance = NSPopoverAppearanceHUD;
        self.popover.behavior = NSPopoverBehaviorTransient;
        NSViewController * vc = [NSViewController new];
        self.popover.contentViewController = vc;
        vc.view = self.view;
        self.popover.contentSize = self.view.frame.size;
    }
    [self.popover showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
}

- (IBAction)confirmButtonPressed:(id)sender {
    self.lastDate = self.datePicker.dateValue;
    [self.delegate performActionAfterSelectDate:self.datePicker.dateValue];
    _isClosePopoverByConfirmButton = YES;
    [self.popover close];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.popover close];
}

#pragma mark - NSPopover delegate
- (void)popoverDidClose:(NSNotification *)notification {
    if (_isClosePopoverByConfirmButton) {
        _isClosePopoverByConfirmButton = NO;
    } else {
        self.datePicker.dateValue = self.lastDate;
    }
    NSLog(@"%@", notification.userInfo);
}

@end
