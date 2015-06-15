//
//  TripLogController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripLogController.h"
#import "TripLogWebServiceController.h"
#import "TripLogCoreDataController.h"

@interface TripLogController ()

@end

@implementation TripLogController

static TripLogController* tripController;
static NSOperationQueue *sharedQueue;

+(id)sharedInstance{
    @synchronized(self){
        if (!tripController) {
            tripController = [[TripLogController alloc] init];
        }
    }
    
    return tripController;
}

-(instancetype)init{
    if(tripController){
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
            tripController = self;
        }
    }
    
    return tripController;
}

-(void)fetchTrips{
    TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
    
    [webController getTripsWithCompletionHandler:^(NSDictionary *result) {
        NSArray* trips = [result objectForKey:@"results"];
        TripLogCoreDataController* coreDataController = [TripLogCoreDataController sharedInstance];
        [coreDataController addTripsFromArray:trips];
    }];
}

@end
