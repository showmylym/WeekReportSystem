//
//  FSMainWindow.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//


#import "FSMainWindow.h"
#import "FSMyWeekReportView.h"
//#import "FSMyProfileView.h"
#import <LogicForMac.h>

@implementation FSMainWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        [self loadingOperations];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    if (self) {
        [self loadingOperations];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private

- (void)loadingOperations {
    [self addNotificationObserver];
}

- (void) addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errorOccured:)
                                                 name:ErrorOccuredNotification
                                               object:nil];
}

#pragma mark - TabView Delegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    if ([tabViewItem.identifier isEqualToString:@"1"]) {
        [self.addRowMenuItem setEnabled:YES];
        [self.saveMenuItem setEnabled:YES];
        [self.deleteRowMenuItem setEnabled:YES];
        [self.exportMenuItem setEnabled:YES];
    } else {
        [self.addRowMenuItem setEnabled:NO];
        [self.saveMenuItem setEnabled:NO];
        [self.deleteRowMenuItem setEnabled:NO];
        [self.exportMenuItem setEnabled:NO];
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    if ([self.defaultTabView.selectedTabViewItem.identifier isEqualToString:@"1"]) {
        [self.addRowMenuItem setEnabled:YES];
        [self.saveMenuItem setEnabled:YES];
        [self.deleteRowMenuItem setEnabled:YES];
        [self.exportMenuItem setEnabled:YES];
    } else {
        [self.addRowMenuItem setEnabled:NO];
        [self.saveMenuItem setEnabled:NO];
        [self.deleteRowMenuItem setEnabled:NO];
        [self.exportMenuItem setEnabled:NO];
    }
}

#pragma mark - Notification
- (void) errorOccured:(NSNotification *)note {
    if (note.userInfo != nil) {
        NSError * error = [note.userInfo valueForKey:@"error"];
        if (error != nil) {
            NSString * errorText = [error.userInfo valueForKey:kErrorMessage];
            NSInteger errorCode = error.code;
            [NSAlert showErrorMessage:[NSString stringWithFormat:@"错误代码：%ld %@", (long)errorCode, errorText]];
        }
    }
}

#pragma mark - Override
- (void)close {
    [[NSApplication sharedApplication] terminate:self];
}

@end
