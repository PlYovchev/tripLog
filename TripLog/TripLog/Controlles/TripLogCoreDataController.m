//
//  TripLogCoreDataController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripLogCoreDataController.h"
#import "Trip+DictionaryInitializator.h"
#import "ToDoItem+DictionaryInitializator.h"
#import "User+DictionaryInitializator.h"
#import "TripLogWebServiceController.h"
#import "TripLogController.h"

#define ID_KEY @"objectId"

@implementation TripLogCoreDataController

static TripLogCoreDataController* coreDataController;

+(id)sharedInstance{
    @synchronized(self){
        if (!coreDataController) {
            coreDataController = [[TripLogCoreDataController alloc] init];
        }
    }
    
    return coreDataController;
}

-(instancetype)init{
    if(coreDataController){
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    }
    else{
        self = [super init];
        if(self){
            coreDataController = self;
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(handleSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
            _searchCriteria = [NSMutableDictionary dictionary];
        }
    }
    
    return coreDataController;
}

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

-(void)handleSaveNotification:(NSNotification *)notification{
    NSManagedObjectContext* context = [notification object];
    if(context.parentContext){
        [context.parentContext performBlock:^{
            [context.parentContext save:nil];
        }];
    }
}

-(NSArray*)usersWithId:(NSString*)userId inContext:(NSManagedObjectContext*)context{
    NSMutableArray *entries = [NSMutableArray array];
    [context performBlockAndWait:^{
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
        NSSortDescriptor* sortByQuantity = [NSSortDescriptor
                                        sortDescriptorWithKey:@"userId" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortByQuantity];
        NSError *error;
        [entries addObjectsFromArray:[context executeFetchRequest:request error:&error]];
    }];
     
    return entries;
}

-(User*)userWithUserId:(NSString*)userId{
    return [self userWithUserId:userId initInContenxt:self.workerManagedObjectContext];
}

-(User*)userWithUserId:(NSString*)userId initInContenxt:(NSManagedObjectContext*)context{
    NSArray* usersWithId = [self usersWithId:userId inContext:context];
    if([usersWithId count] != 0){
        return [usersWithId firstObject];
    }
    
    User* newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    
    TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
    [webController sendGetRequestForUserWithId:userId andCompletitionHandler:^(NSDictionary *result) {
        NSArray* users = [result objectForKey:@"results"];
        if([users count] > 0){
            [newUser setValuesForKeysWithUserInfoDictionary:[users firstObject]];
            [context save:nil];
        }
    }];
    
    return newUser;
}

-(NSArray*)trips{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
    NSSortDescriptor* sortByQuantity = [NSSortDescriptor
                                        sortDescriptorWithKey:@"rating" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortByQuantity];
    NSError *error;
    NSArray *entries = [self.mainManagedObjectContext executeFetchRequest:request
                                                                      error:&error];
    
    return entries;
}

-(NSArray*)tripsWithId:(NSString*)tripId{
    return [self tripsWithId:tripId inContext:self.workerManagedObjectContext];
}

-(NSArray*)tripsWithId:(NSString*)tripId inContext:(NSManagedObjectContext*)context{
    NSMutableArray *entries = [NSMutableArray array];
    [context performBlockAndWait:^{
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
        request.predicate = [NSPredicate predicateWithFormat:@"tripId = %@",tripId];
        NSSortDescriptor* sortByQuantity = [NSSortDescriptor
                                            sortDescriptorWithKey:@"rating" ascending:NO];
        request.sortDescriptors = [NSArray arrayWithObject:sortByQuantity];
        NSError *error;
        [entries addObjectsFromArray:[context executeFetchRequest:request error:&error]];
    }];
    
    return entries;
}

-(void)addTripWithUniqueId:(NSDictionary*)tripProperties{
    NSString* tripId = [tripProperties objectForKey:ID_KEY];
    if([[self tripsWithId:tripId] count] == 0){
        [self addTrip:tripProperties];
    }
}

-(void)addTrip:(NSDictionary*)tripProperties{
    NSManagedObjectContext* context = self.workerManagedObjectContext;
    [context performBlock:^{
        Trip* trip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:context];
        
        NSDictionary* userInfo = [tripProperties objectForKey:@"User"];
        User* creator = [coreDataController userWithUserId:[userInfo objectForKey:ID_KEY] initInContenxt:context];
        
        [trip setValuesForKeysWithTripDictionary:tripProperties andCreator:creator];
        
        [context save:nil];
    }];
}

-(void)addTripsFromArray:(NSArray*)trips{
    [self.workerManagedObjectContext performBlock:^{
        for (NSDictionary* tripProperties in trips) {
            [self addTripWithUniqueId:tripProperties];
        }
    }];
}

-(void)addToDoItem:(NSDictionary*)toDoItemProperties{
    NSManagedObjectContext* context = self.workerManagedObjectContext;
    [context performBlock:^{
        ToDoItem* toDoItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:context];
        
        NSString* userId = [toDoItemProperties objectForKey:TO_DO_USER_ID_KEY];
        NSString* tripId = [toDoItemProperties objectForKey:TO_DO_TRIP_ID_KEY];
    
        User* user = [self userWithUserId:userId initInContenxt:context];
        Trip* trip = [[self tripsWithId:tripId inContext:context] firstObject];
    
        [toDoItem setValuesForKeysWithToDoItemDictionary:toDoItemProperties andUser:user andTrip:trip];
    
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }];
}

#pragma mark - Core Data stack

@synthesize parentManagedObjectContext = _parentManagedObjectContext;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize workerManagedObjectContext = _workerManagedObjectContext;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "triOS.triOSTourDiary" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TripLog" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"tripLog.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(NSManagedObjectContext *)parentManagedObjectContext{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_parentManagedObjectContext != nil) {
        return _parentManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    _parentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_parentManagedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _parentManagedObjectContext;
}

- (NSManagedObjectContext *)mainManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainManagedObjectContext setParentContext:[self parentManagedObjectContext]];
    
    return _mainManagedObjectContext;
}

-(NSManagedObjectContext *)workerManagedObjectContext{
    _workerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_workerManagedObjectContext setParentContext:[self mainManagedObjectContext]];
    
    return _workerManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.parentManagedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark FetchedResultsControllerDelegate

-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip"
                                              inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    
    return _fetchedResultsController;
}

-(NSFetchedResultsController *)toDoListFetchedResultsController{
    if (_toDoListFetchedResultsController != nil) {
        return _toDoListFetchedResultsController;
    }
    
    TripLogController* tripController = [TripLogController sharedInstance];
    Trip* trip = [tripController selectedTrip];
    User* user = [tripController loggedUser];
    
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoItem"
                                              inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"trip = %@ AND user = %@", trip, user];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isDone" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    _toDoListFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    
    return _toDoListFetchedResultsController;
}

@end
