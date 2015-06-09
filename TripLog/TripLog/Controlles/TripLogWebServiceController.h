//
//  TripLogWebServiceController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@protocol TripLogWebServiceControllerDelegate <NSObject>
@optional
// Sign In and Sign Up to Parse
-(void)userDidSignInSuccessfully:(BOOL)isSuccessful;
-(void)userDidSignUpSuccessfully:(BOOL)isSuccessful;

// Fetching or sending objects to Parse
-(void)didRecieveDataSuccessfully: (NSData*)data;
-(void)didNotRecieveData;

-(void)didPostTripSuccessfully;
-(void)didNotPostTripSuccessfully;
@end

@interface TripLogWebServiceController : NSObject

@property (nonatomic, strong) UserModel* loggedUser;
@property id <TripLogWebServiceControllerDelegate> delegate;

+(id)sharedInstance;

#pragma mark Sign In and Sign Up methods
-(void)sendSignInRequestToParseWithUsername:(NSString*)username andPassword:(NSString*)pass;
-(void)sendSignUpRequestToParseWithUsername:(NSString*)username password: (NSString*)pass andPhone: (NSString*)number;

#pragma mark Parse interaction methods

#warning reorder methods!!!!!!!!!!!!!!!
-(void)sendGetRequestForTripCommentWithTripId: (NSString*)tripId;
-(void)sendPostRequestForTripToParseWithName:(NSString*)name country:(NSString*)country city:(NSString*)city description:(NSString*)description raiting:(int)raiting isPrivate:(BOOL)isPrivate userId:(NSString*)userId;

-(void)getTestTrip;
@end
