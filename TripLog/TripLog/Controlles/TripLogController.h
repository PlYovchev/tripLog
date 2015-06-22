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

#define IS_AUTO_SUBMIT_ENABLED_KEY @"autoSubmitKey"
#define IS_AUTO_LOGIN_ENABLED_KEY @"autoLoginKey"

@interface TripLogController : NSObject

@property (nonatomic,strong) Trip *selectedTrip;
@property (nonatomic,strong) User *loggedUser;
@property (nonatomic, copy) NSString* currentSessionToken;
@property (nonatomic, strong) Trip* enteredTripLocation;
@property (nonatomic) BOOL autoSubmitTripToServer;

+(id)sharedInstance;

-(void)fetchTrips;
-(void)saveTrip:(NSDictionary*)tripProperties;

-(bool)tryLogWithSavedUserData;
-(void)logTheUserwithUserId:(NSString *)userId andSessionToken:(NSString *)sessionToken andSaveUserData:(BOOL)shouldSave;

-(void)onEnterRegion;

@end
