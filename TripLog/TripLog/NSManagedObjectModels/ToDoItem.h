//
//  ToDoItem.h
//  TripLog
//
//  Created by plt3ch on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip, User;

@interface ToDoItem : NSManagedObject

@property (nonatomic, retain) NSNumber * isDone;
@property (nonatomic, retain) NSString * task;
@property (nonatomic, retain) NSString * toDoItemId;
@property (nonatomic, retain) NSNumber * isSynchronized;
@property (nonatomic, retain) Trip *trip;
@property (nonatomic, retain) User *user;

@end
