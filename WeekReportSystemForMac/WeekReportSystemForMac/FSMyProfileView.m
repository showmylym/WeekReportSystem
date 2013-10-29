//
//  FSMyProfileView.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSMyProfileView.h"
#import <CommonFunctions.h>
#import <LogicForMac.h>

#define TagClearNameButton           100
#define TagClearIDButton             101

#define TabItemIdentifierReportView        @"1"
#define TabItemIdentifierProfileView       @"2"
#define TabItemIdentifierProjectView       @"3"
#define TabItemIdentifierRequirementsView  @"4"
#define TabItemIdentifierSettingsView      @"5"



@interface FSMyProfileView () {
    BOOL _isFirstShowView;
}

@property NSUserDefaults * userDefaults;

@end

@implementation FSMyProfileView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isFirstShowView = YES;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    if (_isFirstShowView) {
        NSString * nameString = [self.userDefaults valueForKey:kName];
        NSString * idString = [self.userDefaults valueForKey:kID];
        if (!isEmptyString(nameString)) {
            [self.nameTextField setStringValue:nameString];
            [self.nameTextField setEnabled:NO];
        }
        if (!isEmptyString(idString)) {
            [self.idTextField setStringValue:idString];
            [self.idTextField setEnabled:NO];
        }
        _isFirstShowView = NO;
    }
}



#pragma mark - IBAction

- (void)resetAllTextField:(id)sender {
    [self.nameTextField setStringValue:@""];
    [self.idTextField setStringValue:@""];
    [self.nameTextField setEnabled:YES];
    [self.idTextField setEnabled:YES];
    [self.confirmButton setEnabled:YES];
    [self.nameTextField becomeFirstResponder];
}

- (void)resetOneTextField:(id)sender {
    NSButton * clearButton = (NSButton *) sender;
    if (clearButton.tag == TagClearNameButton) {
        [self.nameTextField setStringValue:@""];
        [self.nameTextField setEnabled:YES];
        [self.nameTextField becomeFirstResponder];
    } else if (clearButton.tag == TagClearIDButton) {
        [self.idTextField setStringValue:@""];
        [self.idTextField setEnabled:YES];
        [self.idTextField becomeFirstResponder];
    }
    [self.confirmButton setEnabled:YES];
}

- (void)confirmButtonPressed:(id)sender {
    NSString * nameString = self.nameTextField.stringValue;
    NSString * idString = self.idTextField.stringValue;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@", @"['|\"|<|>|&]+"];
    if ([predicate evaluateWithObject:nameString]) {
        [NSAlert showErrorMessage:@"名字中有非法字符！"];
        return ;
    }
    if ([predicate evaluateWithObject:idString]) {
        [NSAlert showErrorMessage:@"ID中有非法字符！"];
        return ;
    }
    [self.userDefaults setValue:self.nameTextField.stringValue forKey:kName];
    [self.userDefaults setValue:self.idTextField.stringValue forKey:kID];
    if ([self.userDefaults synchronize]) {
        [self.nameTextField setEnabled:NO];
        [self.idTextField setEnabled:NO];
        [self.confirmButton setEnabled:NO];
    }
    NSTabView * tabView = (NSTabView *)self.superview;
    [tabView selectTabViewItemWithIdentifier:TabItemIdentifierReportView];
}

@end
