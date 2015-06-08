//
//  TripLogWebServiceController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol TripLogWebServiceControllerDelegate <NSObject>
@optional
-(void)userDidSignInSuccessfully:(BOOL)isSuccessful;
-(void)userDidSignUpSuccessfully:(BOOL)isSuccessful;
@end

@interface TripLogWebServiceController : NSObject

@property (nonatomic, strong) User*loggedUser;
@property id <TripLogWebServiceControllerDelegate> delegate;

+(id)sharedInstance;
-(void)sendSignInRequestToParseWithUsername:(NSString*)username andPassword:(NSString*)pass;
-(void)sendSignUpRequestToParseWithUsername:(NSString*)username password: (NSString*)pass andPhone: (NSString*)number;


#warning REMOVE TEST METHODS
-(void)uploadTestTrip;
-(void)getTestTripWithQuery;
@end
