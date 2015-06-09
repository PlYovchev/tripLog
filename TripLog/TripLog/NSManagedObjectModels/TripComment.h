//
//  TripComment.h
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip, User;

@interface TripComment : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) Trip *trip;
@property (nonatomic, retain) User *user;

@end
