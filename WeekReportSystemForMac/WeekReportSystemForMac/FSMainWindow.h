//
//  FSMainWindow.h
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSMainWindow : NSWindow
<NSTabViewDelegate, NSMenuDelegate>

@property IBOutlet NSTabView * defaultTabView;

@property IBOutlet NSMenuItem * addRowMenuItem;
@property IBOutlet NSMenuItem * deleteRowMenuItem;
@property IBOutlet NSMenuItem * exportMenuItem;
@property IBOutlet NSMenuItem * saveMenuItem;

@end
