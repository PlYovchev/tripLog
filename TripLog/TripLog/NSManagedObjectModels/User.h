//
//  User.h
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToDoItem, Trip, TripComment;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *tripsCreated;
@property (nonatomic, retain) NSSet *tripsVisited;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) ToDoItem *toDoList;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTripsCreatedObject:(Trip *)value;
- (void)removeTripsCreatedObject:(Trip *)value;
- (void)addTripsCreated:(NSSet *)values;
- (void)removeTripsCreated:(NSSet *)values;

- (void)addTripsVisitedObject:(Trip *)value;
- (void)removeTripsVisitedObject:(Trip *)value;
- (void)addTripsVisited:(NSSet *)values;
- (void)removeTripsVisited:(NSSet *)values;

- (void)addCommentsObject:(TripComment *)value;
- (void)removeCommentsObject:(TripComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
