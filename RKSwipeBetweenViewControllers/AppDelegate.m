//
//  AppDelegate.m
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "AppDelegate.h"

#import "RKSwipeBetweenViewControllers.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    RKSwipeBetweenViewControllers *navigationController = [[RKSwipeBetweenViewControllers alloc]initWithRootViewController:pageController];
    navigationController.navigationViewBackgroundColor = [UIColor clearColor];
    
    //%%% DEMO CONTROLLERS
    UIViewController *demo = [[UIViewController alloc]init];
    UIViewController *demo2 = [[UIViewController alloc]init];
    UIViewController *demo3 = [[UIViewController alloc]init];
    UIViewController *demo4 = [[UIViewController alloc]init];
    UIViewController *demo5 = [[UIViewController alloc]init];
    UIViewController *demo6 = [[UIViewController alloc]init];
    UIViewController *demo7 = [[UIViewController alloc]init];
    demo.view.backgroundColor = [UIColor redColor];
    demo2.view.backgroundColor = [UIColor blueColor];
    demo3.view.backgroundColor = [UIColor grayColor];
    demo4.view.backgroundColor = [UIColor orangeColor];
    demo5.view.backgroundColor = [UIColor blueColor];
    demo6.view.backgroundColor = [UIColor darkGrayColor];
    demo7.view.backgroundColor = [UIColor grayColor];
    

    [navigationController.viewControllerArray addObjectsFromArray:@[demo,demo2,demo3,demo4,demo5,demo6,demo7]];
    [navigationController changeNavigationBarColor:[UIColor clearColor] withTranslucent:YES];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    
//    // Delay execution of my block for 10 seconds.
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [navigationController changeNavigationViewBackgroundColor:[UIColor blackColor] withAnimation:YES];
//        [navigationController changeNavigationBarColor:[UIColor blackColor] withTranslucent:NO];
//    });
//    
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
