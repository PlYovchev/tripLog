//
//  TripLogCoreDataController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripLogCoreDataController.h"
#import "Trip.h"

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
        }
    }
    
    return coreDataController;
}


-(NSArray*)tripsWithId:(NSString*)tripId{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
    request.predicate = [NSPredicate predicateWithFormat:@"tripId = %@",tripId];
    NSSortDescriptor* sortByQuantity = [NSSortDescriptor
                                        sortDescriptorWithKey:@"trip" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortByQuantity];
    NSError *error;
    NSArray *entries = [self.workerManagedObjectContext executeFetchRequest:request
                                                                    error:&error];
    
    return entries;
}

-(void)addTripWithUniqueId:(NSDictionary*)tripProperties{
    NSString* tripId = [tripProperties objectForKey:@"objectId"];
    if([[self tripsWithId:tripId] count] == 0){
        Trip* trip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:self.workerManagedObjectContext];
        [trip setValuesForKeysWithDictionary:tripProperties];
        
        [self.workerManagedObjectContext save:nil];
    }
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"triOSTourDiary" withExtension:@"momd"];
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
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"triOSTourDiary.sqlite"];
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

- (NSManagedObjectContext *)parentManagedObjectContext {
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
    [_mainManagedObjectContext setParentContext:_parentManagedObjectContext];
    
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)workerManagedObjectContext {
    _workerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_workerManagedObjectContext setParentContext:_mainManagedObjectContext];
    
    return _workerManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.mainManagedObjectContext;
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
@end
