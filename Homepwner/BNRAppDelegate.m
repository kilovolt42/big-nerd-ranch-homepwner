//
//  BNRAppDelegate.m
//  Homepwner
//
//  Created by Kyle Stevens on 2/27/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRAppDelegate.h"
#import "BNRItemsViewController.h"
#import "BNRItemStore.h"

@implementation BNRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"%@", NSStringFromSelector(_cmd));
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Create a BNRItemsViewController
	BNRItemsViewController *itemsViewController = [[BNRItemsViewController alloc] init];
	
	// Create an instance of a UINavigationController
	// its stack contains only itemsViewController
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];
	
	// Place navigation controller's view in the window hierarchy
	self.window.rootViewController = navController;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"%@", NSStringFromSelector(_cmd));
	
	BOOL success = [[BNRItemStore sharedStore] saveChanges];
	if (success) {
		NSLog(@"Saved all of the BNRItems");
	} else {
		NSLog(@"Could not save any of the BNRItems");
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
