//
//  ToDoItem+DictionaryInitializator.h
//  TripLog
//
//  Created by plt3ch on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "ToDoItem.h"
#import "Trip.h"
#import "User.h"

#define TO_DO_TASK_KEY @"toDoTask"
#define TO_DO_IS_DONE_KEY @"toDoIsDone"
#define TO_DO_USER_ID_KEY @"userId"
#define TO_DO_TRIP_ID_KEY @"tripId"
#define TO_DO_ITEM_ID_KEY @"objectId"
#define TO_DO_IS_SYNCHRONIZED_KEY @"isSynchronized"

@interface ToDoItem (DictionaryInitializator)

-(void)setValuesForKeysWithToDoItemDictionary:(NSDictionary*)toDoItemProperties
                                      andUser:(User*)user
                                      andTrip:(Trip*) trip;

@end
