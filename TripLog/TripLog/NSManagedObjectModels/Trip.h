//
//  Trip.h
//  TripLog
//
//  Created by plt3ch on 6/20/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToDoItem, TripComment, User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * tripDescription;
@property (nonatomic, retain) NSString * tripId;
@property (nonatomic, retain) NSData * tripImageData;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *creator;
@property (nonatomic, retain) NSSet *toDoList;
@property (nonatomic, retain) NSSet *visitedByUsers;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(TripComment *)value;
- (void)removeCommentsObject:(TripComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addToDoListObject:(ToDoItem *)value;
- (void)removeToDoListObject:(ToDoItem *)value;
- (void)addToDoList:(NSSet *)values;
- (void)removeToDoList:(NSSet *)values;

- (void)addVisitedByUsersObject:(User *)value;
- (void)removeVisitedByUsersObject:(User *)value;
- (void)addVisitedByUsers:(NSSet *)values;
- (void)removeVisitedByUsers:(NSSet *)values;

@end
