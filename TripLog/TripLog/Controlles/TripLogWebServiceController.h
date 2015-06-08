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
-(void)sendSignInRequestToParse:(NSString*)username andWithPassword:(NSString*)pass;
//-(void)sendSignUpRequestToParse:(NSString*)username
@end
