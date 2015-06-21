//
//  ToDoItem+DictionaryInitializator.m
//  TripLog
//
//  Created by plt3ch on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "ToDoItem+DictionaryInitializator.h"

@implementation ToDoItem (DictionaryInitializator)

-(void)setValuesForKeysWithToDoItemDictionary:(NSDictionary*)toDoItemProperties
                                      andUser:(User*)user
                                      andTrip:(Trip*) trip{
    NSString* task = [toDoItemProperties objectForKey:TO_DO_TASK_KEY];
    NSNumber* isDone = [toDoItemProperties objectForKey:TO_DO_IS_DONE_KEY];
    NSString* toDoItemId = [toDoItemProperties objectForKey:TO_DO_ITEM_ID_KEY];
    NSNumber* isSynchronized = [toDoItemProperties objectForKey:TO_DO_IS_SYNCHRONIZED_KEY];
    
    self.task = task;
    self.isDone = isDone;
    self.user = user;
    self.trip = trip;
    self.toDoItemId = toDoItemId;
    self.isSynchronized = isSynchronized;
}

@end
