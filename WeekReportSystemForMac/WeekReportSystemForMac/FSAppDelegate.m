//
//  FSAppDelegate.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSAppDelegate.h"
#import <FSMainLogic.h>
#import "FSAppSettingsView.h"

static NSString * kLastVersion = @"LastVersion";

@implementation FSAppDelegate

- (id)init {
    self = [super init];
    if (self) {
        self.needSave = NO;
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //set preference to userdefaults for new version
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * lastVersion = [userDefaults valueForKey:kLastVersion];
    NSString * thisVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    if (lastVersion == nil || (lastVersion != nil && ![lastVersion isEqualToString:thisVersion])) {
        [userDefaults setValue:thisVersion forKey:kLastVersion];
       
    }
    
    self.window.title = [NSString stringWithFormat:@"四方精创周报系统%@", thisVersion];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (self.needSave) {
        NSAlert * alert = [NSAlert alertWithMessageText:@"退出将会丢失未保存的数据，确认保存吗？" defaultButton:@"保存" alternateButton:@"不保存退出" otherButton:@"取消" informativeTextWithFormat:@""];
        NSInteger clickButtonIndex = [alert runModal];
        if (clickButtonIndex == 1) {
            //save
            [[NSNotificationCenter defaultCenter] postNotificationName:NeedSaveNotification
                                                                object:self
                                                              userInfo:nil];
            return NSTerminateLater;
        }
        if (clickButtonIndex == 0) {
            //exit without saving
            return NSTerminateNow;
        }
        if (clickButtonIndex == -1) {
            //cancel
            return NSTerminateCancel;
        }
    }
    return NSTerminateNow;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"applicationDidBecomeActive");
}

@end
