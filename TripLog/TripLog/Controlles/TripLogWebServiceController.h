//
//  TripLogWebServiceController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "TripLogController.h"

@protocol TripLogWebServiceControllerDelegate <NSObject>
@optional
// Sign In
-(void)userDidSignInSuccessfully:(BOOL)isSuccessful
                      withUserId:(NSString*)userId
                 andSessionToken:(NSString*)sessionToken;

// Fetching or sending objects to Parse
-(void)didRecieveDataSuccessfully: (NSData*)data;
-(void)didNotRecieveData;

-(void)didPostTripSuccessfully;
-(void)didNotPostTripSuccessfully;
@end

@protocol TripLogWebServiceControllerSignUpDelegate <NSObject>
@optional
// Sign Up
-(void)userDidSignUpSuccessfully:(BOOL)isSuccessful;
@end

@interface TripLogWebServiceController : NSObject

@property (nonatomic, strong) UserModel* loggedUser;
@property id <TripLogWebServiceControllerDelegate> delegate;
@property id <TripLogWebServiceControllerSignUpDelegate> signUpDelegate;
@property (nonatomic, strong) NSMutableDictionary *imageURL;
@property (nonatomic, strong) NSString *test;

+(id)sharedInstance;

#pragma mark Sign In and Sign Up methods
-(void)sendSignInRequestToParseWithUsername:(NSString*)username andPassword:(NSString*)pass;
-(void)sendSignUpRequestToParseWithUsername:(NSString*)username password: (NSString*)pass andPhone: (NSString*)number;

#pragma mark Parse interaction methods

-(void)sendGetRequestForAllTripsWithCompletitionHandler: (void (^)(NSDictionary *result)) completition;
-(void)sendPostRequestForTripToParseWithName:(NSString*)name country:(NSString*)country city:(NSString*)city description:(NSString*)description raiting:(int)raiting isPrivate:(BOOL)isPrivate userId:(NSString*)userId withCompletitionHandler: (void (^)(NSDictionary* response)) completition;

-(void)sendGetRequestForTripsWithCompletionHandler:(void (^)(NSDictionary* result)) completion;
-(void)sendGetRequestForUserWithId: (NSString*)userId andCompletitionHandler: (void (^)(NSDictionary *result)) completition;
-(void)sendGetRequestForImagesWithTripId: (NSString*)tripId andCompletitionHandler: (void (^)(NSDictionary *result)) completition;
-(void)sendGetRequestForSingleImageWithTripIdAndHighestRating: (NSString*)tripId andCompletitionHandler: (void (^)(NSDictionary *result)) completition;
@end
