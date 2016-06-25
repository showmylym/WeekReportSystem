//
//  FSMyProjectView.m
//  WeekReportSystemForMac
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSMyProjectView.h"
#import <LogicForMac.h>


#define ProjectNumID        @"ProjectNumColumnID"
#define ProjectNameID       @"ProjectNameColumnID"
#define ProjectCheckedID    @"JoiningColumnID"

#define TagProjectNum       100 
#define TagProjectName      101
#define TagProjectChecked   102

@interface FSMyProjectView () {
    BOOL _isFirstLoad;
}

@property LogicForMac * logicForMac;

@property NSArray * projectInfoArray;
@property NSArray * filteredProjectInfoArray;
@property NSMutableArray * checkedProjectsMuArray;
@property NSMutableArray * uncheckedProjectsMuArray;
@end

@implementation FSMyProjectView

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        //in order to use object self.keyWordSearchField when it isn't nil
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:self.keyWordSearchField];
        [self loadDataFromDatabase];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isFirstLoad = YES;
        self.logicForMac = [LogicForMac new]; 
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private method

- (void)splitCheckedAndUncheckedProjectsInfo:(NSArray *)allProjectsInfo {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isChecked != 0"];
    self.checkedProjectsMuArray = [[allProjectsInfo filteredArrayUsingPredicate:predicate] mutableCopy];
    predicate = [NSPredicate predicateWithFormat:@"isChecked == 0"];
    self.uncheckedProjectsMuArray = [[allProjectsInfo filteredArrayUsingPredicate:predicate] mutableCopy];
}

- (void)loadDataFromDatabase {
    NSArray * allProjectsInfo = [self.logicForMac selectAllProjectsInfos];
    [self splitCheckedAndUncheckedProjectsInfo:allProjectsInfo];
    self.projectInfoArray = [self.checkedProjectsMuArray arrayByAddingObjectsFromArray:self.uncheckedProjectsMuArray];
    self.filteredProjectInfoArray = self.projectInfoArray;

    [self.projectInfoTableView reloadData];
}

#pragma mark - IBAction

- (IBAction)inputButtonPressed:(id)sender {
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    if ([openPanel runModal] == NSOKButton) {
        [self.projectInfoTableView scrollRowToVisible:0];
        
        NSArray * allProjectsInfo = [self.logicForMac projectInfosParsedByXMLFile:openPanel.URL];
        if ([allProjectsInfo count] > 0) {
            //if it was checked in last database, then check it now
            for (FSProjectInfoObject * lastCheckedObj in self.checkedProjectsMuArray) {
                for (FSProjectInfoObject * projectInfoObj in allProjectsInfo) {
                    if ([lastCheckedObj.projectID isEqualToString:projectInfoObj.projectID]) {
                        projectInfoObj.isChecked = lastCheckedObj.isChecked;
                        break;
                    }
                }
            }

            [self splitCheckedAndUncheckedProjectsInfo:allProjectsInfo];
            self.projectInfoArray = [self.checkedProjectsMuArray arrayByAddingObjectsFromArray:self.uncheckedProjectsMuArray];
            self.filteredProjectInfoArray = self.projectInfoArray;
            
            if ([self.logicForMac clearAllProjectsInfoInDatabase]) {
                [self.logicForMac saveInputProjectInfos:self.projectInfoArray];
                [self.logicForMac retrieveIDFromDatabaseByProjectsInfo:self.projectInfoArray];
                [self.projectInfoTableView reloadData];
            } else {
                [NSAlert showErrorMessage:@"数据库中的项目信息清空失败，无法导入！"];
            }

        } else {
            [NSAlert showErrorMessage:@"导入的项目信息文件存在不合法的数据！"];
        }
    }

}

- (IBAction)checkButtonPressed:(id)sender {
    NSButton * button = (NSButton *)sender;
    NSInteger row = [self.projectInfoTableView rowForView:[button superview]];
    FSProjectInfoObject * projectInfoObj = [self.filteredProjectInfoArray objectAtIndex:row];
    projectInfoObj.isChecked = @(button.state);
    if (button.state == 0) {
        if ([self.checkedProjectsMuArray containsObject:projectInfoObj]) {
            [self.checkedProjectsMuArray removeObject:projectInfoObj];
            [self.uncheckedProjectsMuArray addObject:projectInfoObj];
        }
    } else {
        [self.projectInfoTableView scrollRowToVisible:0];

        if (![self.checkedProjectsMuArray containsObject:projectInfoObj]) {
            [self.uncheckedProjectsMuArray removeObject:projectInfoObj];
            [self.checkedProjectsMuArray addObject:projectInfoObj];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ProjectCheckingChangedNotification
                                                        object:self
                                                      userInfo:@{@"projectNameInfos":(NSArray *)self.checkedProjectsMuArray}];
    [self.logicForMac saveProjectInfo:projectInfoObj];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isChecked" ascending:NO];
    self.filteredProjectInfoArray = [self.filteredProjectInfoArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.projectInfoTableView reloadData];
    NSLog(@"rowForView:%ld", [self.projectInfoTableView rowForView:[sender superview]]);
}

#pragma mark - Notification

- (void) textDidChange:(NSNotification *) note {
    [self.projectInfoTableView scrollRowToVisible:0];
    NSString * keyWord = [self.keyWordSearchField.cell title];

    if (isEmptyString(keyWord)) {
        self.projectInfoArray = [self.checkedProjectsMuArray arrayByAddingObjectsFromArray:self.uncheckedProjectsMuArray];
        self.filteredProjectInfoArray = self.projectInfoArray;
    } else {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"projectID contains[CD] %@ or projectName contains[CD] %@", keyWord, keyWord];
        self.filteredProjectInfoArray = [self.projectInfoArray filteredArrayUsingPredicate:predicate];
    }
    [self.projectInfoTableView reloadData];
}

#pragma mark - NSTableView delegate and datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.filteredProjectInfoArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString * columnIdentifier = [tableColumn identifier];
    NSTableCellView * cellView = [tableView makeViewWithIdentifier:columnIdentifier owner:self];
    if ([columnIdentifier isEqualToString:ProjectNumID]) {
        NSTextField * projectIDTextField = (NSTextField *) [cellView viewWithTag:TagProjectNum];
        NSString * projectIDString = [[self.filteredProjectInfoArray objectAtIndex:row] projectID];
        [projectIDTextField.cell setTitle:projectIDString];
    }
    if ([columnIdentifier isEqualToString:ProjectNameID]) {
        NSTextField * projectNameTextField = (NSTextField *) [cellView viewWithTag:TagProjectName];
        NSString * projectNameString = [[self.filteredProjectInfoArray objectAtIndex:row] projectName];
        [projectNameTextField.cell setTitle:projectNameString];
    }
    if ([columnIdentifier isEqualToString:ProjectCheckedID]) {
        NSButton * isJoinedButton = (NSButton *) [cellView viewWithTag:TagProjectChecked];
        isJoinedButton.state = [[[self.filteredProjectInfoArray objectAtIndex:row] isChecked] integerValue];
        
    }
    return cellView;
}

@end

NSString * const ProjectCheckingChangedNotification = @"ProjectCheckingChangedNotification";
