//
//  TripLogLocationController.m
//  TripLog
//
//  Created by plt3ch on 6/13/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "TripLogLocationController.h"

@interface TripLogLocationController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLAuthorizationStatus status;

@end

@implementation TripLogLocationController

static TripLogLocationController* locationController;

+(id)sharedInstance{
    @synchronized(self){
        if (!locationController) {
            locationController = [[TripLogLocationController alloc] init];
        }
    }
    
    return locationController;
}

-(instancetype)init{
    if(locationController){
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
            locationController = self;
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            
            [CLLocationManager authorizationStatus];
            
            //[self.locationManager startUpdatingLocation];
        }
    }
    
    return locationController;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    self.status = status;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [manager requestAlwaysAuthorization];
            break;
        default:
            break;
    }
}

-(void)startMonitorTripLocation:(Trip*) trip{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([trip.latitude doubleValue], [trip.longitude doubleValue]);
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coord radius:200.f identifier:trip.tripId];
    
    [self.locationManager startMonitoringForRegion:region];
}

-(void)stopMonitorTripLocation:(Trip*)trip{
    NSSet* monitoredRegions = [self.locationManager monitoredRegions];
    for (CLRegion* region in monitoredRegions) {
        if([region.identifier isEqual:trip.tripId]){
             [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region{
    CLCircularRegion* circularRegion = (CLCircularRegion*)region;    
    NSLog(@"enter region %f %f", circularRegion.center.latitude, circularRegion.center.longitude);
//    [manager stopMonitoringForRegion:circularRegion];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody = @"Location has been reached!";
    // Set the action button
    localNotif.alertAction = @"View";
    
    localNotif.soundName = @"example.caf";
 //   localNotif.applicationIconBadgeNumber = 1;
    
    // Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    localNotif.userInfo = infoDict;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}


@end
