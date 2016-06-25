//
//  FSAppSettingsView.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define WeekReportSystemIdentifier      [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"]


@interface FSAppSettingsView : NSView
<NSControlTextEditingDelegate>

@property (weak) IBOutlet NSTextField * serverAddress;

- (IBAction)resetButtonPressed:(id)sender;

@end
