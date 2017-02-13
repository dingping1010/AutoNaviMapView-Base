//
//  AppDelegate.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/2/13.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import "AppDelegate.h"
#import "RESideMenu.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

#import "MainViewController.h"
#import "MenuViewController.h"
static  NSString *const mapKey = @"4aa7015ac48b9fed617bb6517dbb9128";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self initKey];
    
    [self initWindow];

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

- (void)initKey
{
    [[AMapServices sharedServices] setApiKey:mapKey];
    [[AMapServices sharedServices] setEnableHTTPS:YES];
}

- (void)initWindow
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    MenuViewController *menuViewController = [[MenuViewController alloc] init];

    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:menuViewController
                                                                   rightMenuViewController:nil];
    
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"timg"];
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
    self.window.rootViewController = sideMenuViewController;
    [self.window makeKeyAndVisible];

}


@end
