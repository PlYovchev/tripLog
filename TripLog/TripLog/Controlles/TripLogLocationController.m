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
#import "TripLogController.h"

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
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            
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
    TripLogController* tripController = [TripLogController sharedInstance];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([trip.latitude doubleValue], [trip.longitude doubleValue]);
    CLLocationDistance radius = 1000;
    NSString* regionIdentifier = [NSString stringWithFormat:@"%@ %@", trip.tripId, tripController.loggedUser.userId];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coord
                                                                 radius:radius
                                                             identifier:regionIdentifier];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
//    [self.locationManager requestStateForRegion:region];
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
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = @"Location has been reached!";
    localNotif.alertAction = @"View";
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:region.identifier forKey:TRIP_ENTER_REGION_KEY];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    CLCircularRegion* circularRegion = (CLCircularRegion*)region;
    NSLog(@"failed for region %f %f", circularRegion.center.latitude, circularRegion.center.longitude);
}

-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region {
    CLCircularRegion* circularRegion = (CLCircularRegion*)region;
 //   [manager stopMonitoringForRegion:circularRegion];
    TripLogController* tripController = [TripLogController sharedInstance];
    tripController.enteredTripLocation = nil;
}


@end
