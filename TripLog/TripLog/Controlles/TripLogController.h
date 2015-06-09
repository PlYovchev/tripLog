//
//  TripLogController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripLogController : NSObject

+(id)sharedInstance;

-(void)fetchTrips;

@end
