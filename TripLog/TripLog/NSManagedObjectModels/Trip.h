//
//  Trip.h
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToDoItem, TripComment, User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) User *creator;
@property (nonatomic, retain) NSSet *visitedByUsers;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) ToDoItem *toDoList;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addVisitedByUsersObject:(User *)value;
- (void)removeVisitedByUsersObject:(User *)value;
- (void)addVisitedByUsers:(NSSet *)values;
- (void)removeVisitedByUsers:(NSSet *)values;

- (void)addCommentsObject:(TripComment *)value;
- (void)removeCommentsObject:(TripComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
