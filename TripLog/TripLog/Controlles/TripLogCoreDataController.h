//
//  TripLogCoreDataController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

@interface TripLogCoreDataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *parentManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *workerManagedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableDictionary* searchCriteria;

+(id)sharedInstance;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(NSArray*)trips;
-(NSArray*)tripsWithId:(NSString*)tripId;
-(void)addTripWithUniqueId:(NSDictionary*)tripProperties;
-(void)addTripsFromArray:(NSArray*)trips;

@end
