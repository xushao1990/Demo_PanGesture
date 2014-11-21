//
//  AppDelegate.m
//  Demo_PanGesture
//
//  Created by Tongtong Xu on 14/11/21.
//  Copyright (c) 2014年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "TTXTransition.h"
#import "NormalViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TTXTransition validatePanBackGesture];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    NormalViewController *normal = [[NormalViewController alloc] init];
    UINavigationController *root =[[UINavigationController alloc] initWithRootViewController:normal];
    self.window.rootViewController = root;
    [self.window makeKeyWindow];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
