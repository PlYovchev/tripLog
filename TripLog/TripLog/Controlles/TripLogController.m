//
//  TripLogController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripLogController.h"
#import "TripLogWebServiceController.h"
#import "TripLogCoreDataController.h"
#import "AppDelegate.h"
#import "LocationDetailsViewController.h"
#import "Trip+DictionaryInitializator.h"

#define HAS_SAVED_USER_DATA_KEY @"hasUserDataKey"
#define USER_ID_KEY @"userId"
#define SESSION_KEY @"sessionKey"

@interface TripLogController ()

@property (nonatomic) NSTimer* refreshTimer;

@end

@implementation TripLogController

static TripLogController* tripController;
static NSOperationQueue *sharedQueue;

+(id)sharedInstance{
    @synchronized(self){
        if (!tripController) {
            tripController = [[TripLogController alloc] init];
        }
    }
    
    return tripController;
}

-(instancetype)init{
    if(tripController){
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    }
    else{
        self = [super init];
        if(self){
            tripController = self;
            [self setInitialValuesFromUserDefaults];
        }
    }
    
    return tripController;
}

-(void)setInitialValuesFromUserDefaults{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    _autoSubmitTripToServer = [userDefaults objectForKey:@"autoSubmitKey"];
}

-(void)fetchTrips{
    TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
    
    [webController sendGetRequestForTripsWithCompletionHandler:^(NSDictionary *result) {
        NSArray* trips = [result objectForKey:@"results"];
        TripLogCoreDataController* coreDataController = [TripLogCoreDataController sharedInstance];
        [coreDataController addTripsFromArray:trips];
    }];
    
    NSLog(@"fetched");
}

-(void)saveTrip:(NSDictionary*)tripProperties{
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController addTrip:tripProperties];
    
    if ([[tripProperties objectForKey:IS_PRIVATE_KEY] boolValue] == NO || [[TripLogController sharedInstance] autoSubmitTripToServer]){
        NSString* tripId = [tripProperties objectForKey:ID_KEY];
        NSString* name = [tripProperties objectForKey:NAME_KEY];
        NSString* city = [tripProperties objectForKey:CITY_KEY];
        NSString* country = [tripProperties objectForKey:COUNTRY_KEY];
        NSString* tripDescription = [tripProperties objectForKey:DESCRIPTION_KEY];
        NSNumber* isPrivate = [tripProperties objectForKey:IS_PRIVATE_KEY];
        
        NSDictionary* location = [tripProperties objectForKey:LOCATION_KEY];
        NSNumber* latitude = [location objectForKey:LATITUDE_KEY];
        NSNumber* longitude = [location objectForKey:LONGITUDE_KEY];
        
        TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
        [webController sendPostRequestForTripToParseWithName:name country:country city:city description:tripDescription raiting:0 isPrivate:[isPrivate boolValue] latitude:latitude longitude:longitude  userId:self.loggedUser.userId withCompletitionHandler:^(NSDictionary *response) {
            TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
            NSManagedObjectContext* context = dataController.workerManagedObjectContext;
            Trip* trip = [[dataController tripsWithId:tripId inContext:context] firstObject];
            trip.tripId = [response objectForKey:ID_KEY];
            [context performBlockAndWait:^{
                [context save:nil];
            }];
            Trip* newTrip = [[dataController tripsWithId:[response objectForKey:ID_KEY]] firstObject];
            NSLog(@"%@ %@", newTrip.tripId, newTrip.name);
        }];
    }
}

-(bool)tryLogWithSavedUserData{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![userDefaults boolForKey:IS_AUTO_LOGIN_ENABLED_KEY]) {
        return NO;
    }
    
    BOOL hasSavedUserData = [userDefaults boolForKey:HAS_SAVED_USER_DATA_KEY];
    if(!hasSavedUserData){
        return NO;
    }
    
    NSString* userId = [userDefaults objectForKey:USER_ID_KEY];
    NSString* sessionToken = [userDefaults objectForKey:SESSION_KEY];
    
    [self logTheUserwithUserId:userId andSessionToken:sessionToken andSaveUserData:NO];
    
    return YES;
}

-(void)logTheUserwithUserId:(NSString *)userId andSessionToken:(NSString *)sessionToken andSaveUserData:(BOOL)shouldSave{
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController.mainManagedObjectContext performBlockAndWait:^{
        User* loggedUser = [dataController userWithUserId:userId initInContenxt:dataController.mainManagedObjectContext];
        
        TripLogController* tripController = [TripLogController sharedInstance];
        tripController.loggedUser = loggedUser;
        tripController.currentSessionToken = sessionToken;
        
        [dataController.mainManagedObjectContext save:nil];
    }];

    if(shouldSave){
        [self saveUserDataInUserDefaultsWithUserId:userId andSessionToken:sessionToken];
    }
    
    [self presentTripTabBarViewController];
}

-(void)stopRefreshTimer{
    [self.refreshTimer invalidate];
}

-(void)saveUserDataInUserDefaultsWithUserId:(NSString*)userId andSessionToken:(NSString*)sessionToken{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:HAS_SAVED_USER_DATA_KEY];
    [userDefaults setObject:userId forKey:USER_ID_KEY];
    [userDefaults setObject:sessionToken forKey:SESSION_KEY];
    
    [userDefaults synchronize];
}

-(void)presentTripTabBarViewController{
    if ([NSThread isMainThread]) {
        [self fetchTrips];
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(fetchTrips) userInfo:nil repeats:YES];

        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController* controller = [storyboard instantiateViewControllerWithIdentifier:@"TripTabViewController"];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = controller;
        [appDelegate.window makeKeyAndVisible];
    } else {
        //Or call the same method on main thread
        [self performSelectorOnMainThread:@selector(presentTripTabBarViewController)
                               withObject:nil waitUntilDone:NO];
    }
}

-(void)onEnterRegion{
    [self.loggedUser addTripsVisitedObject:self.enteredTripLocation];
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController.mainManagedObjectContext save:nil];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController* tabController = [storyboard instantiateViewControllerWithIdentifier:@"TripTabViewController"];
    LocationDetailsViewController* locationDetailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:locationDetailsViewController];
    locationDetailsViewController.atTripLocation = YES;
    NSMutableArray* viewControllers = [NSMutableArray arrayWithObject:navController];
    [viewControllers addObjectsFromArray:[tabController viewControllers]];
    tabController.viewControllers = viewControllers;
    
    navController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"At trip location!"
                                                                           image:[UIImage imageNamed:@"alltrips.png"]
                                                                             tag:5];
    [navController.tabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateNormal];
    [navController.tabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateSelected];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = tabController;
    [appDelegate.window makeKeyAndVisible];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                             message:@"You arrived at trip location!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [alertController addAction:okAction];
    [tabController.selectedViewController presentViewController:alertController animated:YES completion:nil];
}

-(void)onExitRegion{
    self.enteredTripLocation = nil;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController* tabController = [storyboard instantiateViewControllerWithIdentifier:@"TripTabViewController"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = tabController;
    [appDelegate.window makeKeyAndVisible];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Exit!"
                                                                             message:@"You left the trip location!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [alertController addAction:okAction];
    [tabController.selectedViewController presentViewController:alertController animated:YES completion:nil];
}

@end
