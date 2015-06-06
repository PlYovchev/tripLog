//
//  TripLogWebServiceController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripLogWebServiceController : NSObject

+(id)sharedInstance;
-(void)sendLoginRequestToParse:(NSString*)username andWithPassword:(NSString*)pass;

@end
