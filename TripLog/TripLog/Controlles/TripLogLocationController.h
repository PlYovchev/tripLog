//
//  TripLogLocationController.h
//  TripLog
//
//  Created by plt3ch on 6/13/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"

#define TRIP_ENTER_REGION_KEY @"tripEnterRegion"

@interface TripLogLocationController : NSObject

+(id)sharedInstance;

-(void)startMonitorTripLocation:(Trip*) trip;
-(void)stopMonitorTripLocation:(Trip*) trip;
-(void)stopMonitorAllTripLocations;

@end
