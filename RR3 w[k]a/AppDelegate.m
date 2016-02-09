//
//  AppDelegate.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  NSMutableArray *defaultMemory = [[NSMutableArray alloc] initWithArray:[NSMutableArray arrayWithObjects: @"Cars that can be purchased with R$",@"Cars that can be purchased with gold", nil]];
    //[NSMutableArray arrayWithObjects: @"Cars that can be purchased with R$‏‎", @"Cars that can be purchased with gold‏‎",@"Cars that can be won in special events‏‎", nil]
    //[NSMutableArray arrayWithObjects: @"Cars A-Z", @"0-10 PR Cars", nil]
  NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObjectsAndKeys:
                                 defaultMemory, HSMEMORY, nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  
  NSString *baseURL = [NSString stringWithFormat:@"http://rr3.wikia.com/"];
  
  
  [[NSUserDefaults standardUserDefaults] setObject:baseURL forKey:@"baseURL" ];

  NSDictionary *addingEnabled = [NSDictionary dictionaryWithObject:@"NO"
                                                            forKey:@"enabled_adding_list"];
  [[NSUserDefaults standardUserDefaults] registerDefaults:addingEnabled];
  NSDictionary *editingEnabled = [NSDictionary dictionaryWithObject:@"NO"
                                                               forKey:@"enabled_deleting_list"];
  [[NSUserDefaults standardUserDefaults] registerDefaults:editingEnabled];
  NSDictionary *linksEnabled = [NSDictionary dictionaryWithObject:@"NO"
                                                             forKey:@"enabled_links"];
  [[NSUserDefaults standardUserDefaults] registerDefaults:linksEnabled];
  [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
