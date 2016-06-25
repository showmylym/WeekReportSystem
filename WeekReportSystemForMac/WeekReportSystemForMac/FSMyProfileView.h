//
//  FSMyProfileView.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSMyProfileView : NSView

@property (weak) IBOutlet NSTextField * nameTextField;
@property (weak) IBOutlet NSTextField * idTextField;
@property (weak) IBOutlet NSButton * confirmButton;

- (IBAction)resetAllTextField:(id)sender;
- (IBAction)confirmButtonPressed:(id)sender;
- (IBAction)resetOneTextField:(id)sender;

@end
