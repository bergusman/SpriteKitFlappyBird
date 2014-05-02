//
//  AppDelegate.m
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 30/04/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import "AppDelegate.h"

#import "GameViewController.h"

@implementation AppDelegate

#pragma mark - Setups

- (void)setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
}

- (void)showGameVC {
    GameViewController *gameVC = [[GameViewController alloc] init];
    self.window.rootViewController = gameVC;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupWindow];
    [self showGameVC];
    return YES;
}

@end
