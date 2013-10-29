//
//  FSAppDelegate.m
//  WeekReportSystemForiOS
//
//  Created by Leiyiming on 13-5-31.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSReportMainViewController.h"
#import "FSPersonInfoViewController.h"
#import "FSProjectInfoViewController.h"
#import "FSSettingsViewController.h"
#import <LogicForiOS.h>


@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    LogicForiOS * logicForiOS = [LogicForiOS new];
    
    UITabBarController * tabBarController = [UITabBarController new];
    
    FSReportMainViewController * reportViewController = [FSReportMainViewController new];
    reportViewController.title = @"我的周报";
    reportViewController.tabBarItem.title = reportViewController.title;
    UINavigationController * navController1 = [[UINavigationController alloc] initWithRootViewController:reportViewController];
    
    FSPersonInfoViewController * personInfoViewController = [FSPersonInfoViewController new];
    personInfoViewController.title = @"我的资料";
    personInfoViewController.tabBarItem.title = personInfoViewController.title;
    UINavigationController * navController2 = [[UINavigationController alloc] initWithRootViewController:personInfoViewController];
    
    FSProjectInfoViewController * projectInfoController = [FSProjectInfoViewController new];
    projectInfoController.title = @"我的项目";
    projectInfoController.tabBarItem.title = projectInfoController.title;
    UINavigationController * navController3 = [[UINavigationController alloc] initWithRootViewController:projectInfoController];
    
    FSSettingsViewController * settingsViewController = [FSSettingsViewController new];
    settingsViewController.title = @"参数设置";
    settingsViewController.tabBarItem.title = settingsViewController.title;
    UINavigationController * navController4 = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    tabBarController.viewControllers = @[navController1,navController2,navController3,navController4];

    self.window.rootViewController = tabBarController;
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
