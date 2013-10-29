//
//  FSAppSettingsView.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kAutoRunMemoryClean             @"isAutoRunMemoryClean"
#define kAutoRunWeekReport              @"isAutoRunWeekReport"
#define AutoCleanMemoryIdentifier       @"FormsSyntron.AutoCleanMemory"
#define WeekReportSystemIdentifier      [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"]


@interface FSAppSettingsView : NSView
<NSControlTextEditingDelegate>

@property (weak) IBOutlet NSTextField * serverAddress;


@property (weak) IBOutlet NSButton * runAutoMemoryCleanButton;
@property (weak) IBOutlet NSButton * runThisAppButton;


- (IBAction)runAutoMemoryCleanButtonPressed:(id)sender;
- (IBAction)runThisAppButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;

@end
