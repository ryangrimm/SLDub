//
//  SLAppDelegate.m
//  SLDub-Example
//
//  Created by Ryan Grimm on 9/8/14.
//  Copyright (c) 2014 Swell Lines LLC. All rights reserved.
//

#import "SLAppDelegate.h"
#import "SLViewController.h"

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SLViewController *viewController = [[SLViewController alloc] initWithNibName:nil bundle:nil];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
