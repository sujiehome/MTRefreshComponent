//
//  AppDelegate.m
//  MTRefreshComponentExample
//
//  Created by suyuxuan on 2017/7/4.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self mt_refreshConfig];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Config
- (void)mt_refreshConfig
{
    //设置头部刷新控件文案
    [MTRefreshConfig shared].headerIdleText = @"默认状态";
    [MTRefreshConfig shared].headerTriggerText = @"触发状态";
    [MTRefreshConfig shared].headerRefreshingText = @"刷新状态";
    [MTRefreshConfig shared].headerFont = [UIFont systemFontOfSize:16];
    [MTRefreshConfig shared].headerTextColor = [UIColor grayColor];
    
    //设置尾部刷新控件文案
    [MTRefreshConfig shared].footerIdleText = @"默认状态";
    [MTRefreshConfig shared].footerTriggerText = @"触发状态";
    [MTRefreshConfig shared].footerRefreshingText = @"刷新状态";
    [MTRefreshConfig shared].footerNoMoreDataText = @"没有更多数据";
    [MTRefreshConfig shared].footerFont = [UIFont systemFontOfSize:16];
    [MTRefreshConfig shared].footerTextColor = [UIColor grayColor];
    
    //设置自定义视图
    [MTRefreshConfig shared].customTopView = @"CustomRefreshView";
    [MTRefreshConfig shared].customNullDataView = @"";
}


@end
