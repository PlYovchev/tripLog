//
//  TripLogController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"
#import "User.h"

@interface TripLogController : NSObject
@property (nonatomic,strong) Trip *selectedTrip;
@property (nonatomic,strong) User *user;


+(id)sharedInstance;

-(void)fetchTrips;
-(void)saveTrip:(NSDictionary*)tripProperties;

@end
