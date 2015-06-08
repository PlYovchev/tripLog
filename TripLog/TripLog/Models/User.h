//
//  User.h
//  TripLog
//
//  Created by svetoslavpopov on 6/8/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString*username;
@property (nonatomic, strong) NSString*phone;
@property (nonatomic, strong) NSDate*createdAt;
@property (nonatomic, strong) NSDate*updatedAt;
@property (nonatomic, strong) NSString*objectId;
@property (nonatomic, strong) NSString*sessionToken;

@end
