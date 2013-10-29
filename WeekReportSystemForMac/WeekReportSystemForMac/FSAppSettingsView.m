//
//  FSAppSettingsView.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSAppSettingsView.h"
#import <LogicForMac.h>
#import "FSMainWindow.h"

#import <LaunchAtLoginController.h>


@interface FSAppSettingsView () {
    BOOL _isFirstLoad;
}

@property LaunchAtLoginController * launchAtLoginController;

@property NSUserDefaults * userDefaults;

@end

@implementation FSAppSettingsView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isFirstLoad = YES;
        self.launchAtLoginController = [[LaunchAtLoginController alloc] init];
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        if ([self.userDefaults boolForKey:kAutoRunMemoryClean]) {
            self.runAutoMemoryCleanButton.state = 1;
        } else {
            self.runAutoMemoryCleanButton.state = 0;
        }
        
        if ([self.userDefaults boolForKey:kAutoRunWeekReport]) {
            self.runThisAppButton.state = 1;
        } else {
            self.runThisAppButton.state = 0;
        }
        [self.serverAddress.cell setTitle:[self.userDefaults valueForKey:kServerAddress]];
        
    }
}

#pragma mark - IBAction
- (void)runAutoMemoryCleanButtonPressed:(id)sender {
    NSString * autoCleanMemoryAppPath = [[NSBundle mainBundle] pathForResource:@"AutoCleanMemory" ofType:@"app"];
    NSURL * autoCleanMemoryAppURL = [[NSURL alloc] initFileURLWithPath:autoCleanMemoryAppPath isDirectory:YES];

    NSButton * button = (NSButton *)sender;
    if (button.state) {
        [[NSWorkspace sharedWorkspace] launchApplication:autoCleanMemoryAppPath];
        [self.launchAtLoginController setLaunchAtLogin:YES forURL:autoCleanMemoryAppURL];
        [self.userDefaults setBool:YES forKey:kAutoRunMemoryClean];
    } else {
        NSArray * arrayRunningApps = [[NSWorkspace sharedWorkspace] runningApplications];
        for (NSRunningApplication * runningApp in arrayRunningApps) {
            if ([runningApp.bundleIdentifier isEqualToString:AutoCleanMemoryIdentifier]) {
                [runningApp terminate];
            }
        }
        [self.launchAtLoginController setLaunchAtLogin:NO forURL:autoCleanMemoryAppURL];
        [self.userDefaults setBool:NO forKey:kAutoRunMemoryClean];

    }
}

- (void)runThisAppButtonPressed:(id)sender {
    NSButton * button = (NSButton *)sender;
    NSURL * weekReportAppURL = [[NSBundle mainBundle] bundleURL];
    if (button.state) {
        [self.launchAtLoginController setLaunchAtLogin:YES forURL:weekReportAppURL];
        [self.userDefaults setBool:YES forKey:kAutoRunWeekReport];
    } else {
        [self.launchAtLoginController setLaunchAtLogin:NO forURL:weekReportAppURL];
        [self.userDefaults setBool:NO forKey:kAutoRunWeekReport];
    }
}

- (void)resetButtonPressed:(id)sender {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [self.serverAddress.cell setTitle:DefaultServerAddress];
    [userDefaults setValue:DefaultServerAddress forKey:kServerAddress];
    [userDefaults synchronize];
}

#pragma mark - NSTextField delegate
- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSTextField * textField = (NSTextField *)[obj object];
    if (textField == self.serverAddress) {
        NSString * serverURLString = [textField.cell title];
        if ([serverURLString rangeOfString:@"://"].location == NSNotFound) {
            serverURLString = [@"http://" stringByAppendingString:[textField.cell title]];
        }
        [textField.cell setTitle:serverURLString];
        [userDefaults setValue:serverURLString forKey:kServerAddress];
    }
    [userDefaults synchronize];
}

@end
