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


@interface FSAppSettingsView () {
    BOOL _isFirstLoad;
}

@property NSUserDefaults * userDefaults;

@end

@implementation FSAppSettingsView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isFirstLoad = YES;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        [self resetButtonPressed:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    if (_isFirstLoad) {
        _isFirstLoad = NO;
    
        [self.serverAddress.cell setTitle:[self.userDefaults valueForKey:kServerAddress]];
    }
}

#pragma mark - IBAction

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
