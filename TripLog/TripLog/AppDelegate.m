//
//  AppDelegate.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AppDelegate.h"
#import "TripLogController.h"
#import "TripLogCoreDataController.h"
#import "TripLogWebServiceController.h"
#import "TripLogLocationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication* app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
    [app setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [TripLogLocationController sharedInstance];
    
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [self application:nil didReceiveLocalNotification:localNotif];
    }
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSString* identifier = [[notification userInfo] objectForKey:TRIP_ENTER_REGION_KEY];
    if(identifier){
        NSArray* ids = [identifier componentsSeparatedByString:@" "];
        if([ids count] == 2){
            NSString* tripId = ids[0];
            NSString* userId = ids[1];
            TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
            Trip* enteredTripLocation = [[dataController tripsWithId:tripId inContext:dataController.mainManagedObjectContext] firstObject];
            User* user = [dataController userWithUserId:userId initInContenxt:dataController.mainManagedObjectContext];
            TripLogController* tripController = [TripLogController sharedInstance];
            tripController.enteredTripLocation = enteredTripLocation;
            tripController.loggedUser = user;
            [tripController onEnterRegion];
            NSLog(@"%@", tripId);
            
            UIApplication* app = [UIApplication sharedApplication];
            app.applicationIconBadgeNumber = 0;
        }
    }
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
    // Saves changes in the application's managed object context before the application terminates.
    
    TripLogCoreDataController* coreDataController = [TripLogCoreDataController sharedInstance];
    [coreDataController saveContext];
}

@end
