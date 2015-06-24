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

#define REGION_RADIUS 1000

@interface TripLogLocationController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLAuthorizationStatus status;
@property (nonatomic) NSMutableArray* lastSubmitedRegions;

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
        }
    }
    
    return locationController;
}

-(NSMutableArray *)lastSubmitedRegions{
    if(!_lastSubmitedRegions){
        _lastSubmitedRegions = [NSMutableArray array];
    }
    
    return _lastSubmitedRegions;
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
    NSString* regionIdentifier = [NSString stringWithFormat:@"%@ %@", trip.tripId, tripController.loggedUser.userId];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coord
                                                                 radius:REGION_RADIUS
                                                             identifier:regionIdentifier];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
//  Cant determine the state for the region for some reason!
//    [self.locationManager requestStateForRegion:region];
    [self.lastSubmitedRegions addObject:region];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        for (CLCircularRegion* circularRegion in self.lastSubmitedRegions) {
            if([circularRegion containsCoordinate:coord]){
                [self locationManager:manager didEnterRegion:circularRegion];
            }
            
            [self.locationManager startMonitoringForRegion:circularRegion];
        }
        
        [self.lastSubmitedRegions removeAllObjects];
        [self.locationManager stopUpdatingLocation];
    }
}

-(void)stopMonitorTripLocation:(Trip*)trip{
    TripLogController* tripController = [TripLogController sharedInstance];
    NSString* regionIdentifier = [NSString stringWithFormat:@"%@ %@", trip.tripId, tripController.loggedUser.userId];
    NSSet* monitoredRegions = [self.locationManager monitoredRegions];
    for (CLRegion* region in monitoredRegions) {
        if([region.identifier isEqual:regionIdentifier]){
             [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

-(void)stopMonitorAllTripLocations{
    NSSet* monitoredRegions = [self.locationManager monitoredRegions];
    for (CLRegion* region in monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
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
    localNotif.applicationIconBadgeNumber =+1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    CLCircularRegion* circularRegion = (CLCircularRegion*)region;
    NSLog(@"failed for region %f %f", circularRegion.center.latitude, circularRegion.center.longitude);
}

-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region {
 //   [manager stopMonitoringForRegion:circularRegion];
    TripLogController* tripController = [TripLogController sharedInstance];
    tripController.enteredTripLocation = nil;
    [tripController onExitRegion];
}


@end
