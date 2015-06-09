//
//  Trip.m
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "Trip.h"
#import "ToDoItem.h"
#import "TripComment.h"
#import "User.h"


@implementation Trip

@dynamic id;
@dynamic name;
@dynamic country;
@dynamic city;
@dynamic latitude;
@dynamic longitude;
@dynamic rating;
@dynamic isPrivate;
@dynamic creator;
@dynamic visitedByUsers;
@dynamic comments;
@dynamic toDoList;

@end
