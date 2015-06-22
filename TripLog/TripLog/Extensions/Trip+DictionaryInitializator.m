//
//  Trip+DictionaryInitializator.m
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "Trip+DictionaryInitializator.h"
#import "TripLogCoreDataController.h"

@implementation Trip (DictionaryInitializator)

-(void)setValuesForKeysWithTripDictionary:(NSDictionary*)tripDictionary andCreator:(User*)creator{
    self.tripId = [tripDictionary objectForKey:ID_KEY];
    self.name = [tripDictionary objectForKey:NAME_KEY];
    self.city = [tripDictionary objectForKey:CITY_KEY];
    self.country = [tripDictionary objectForKey:COUNTRY_KEY];
    self.rating = [tripDictionary objectForKey:RATING_KEY];
    self.tripDescription = [tripDictionary objectForKey:DESCRIPTION_KEY];
    self.imageUrl = [tripDictionary objectForKey:IMAGE_URL_KEY];
    self.isPrivate = [tripDictionary objectForKey:IS_PRIVATE_KEY];
    self.creator = creator;
    
    NSDictionary* location = [tripDictionary objectForKey:LOCATION_KEY];
    self.latitude = [location objectForKey:LATITUDE_KEY];
    self.longitude = [location objectForKey:LONGITUDE_KEY];
    
    NSLog(@"%@ %@ %@ %@ %@ %@", self.tripId, self.name, self.rating, self.latitude, self.longitude, self.creator.userId);
}

-(void)requestImageDataWithCompletionHandler:(void (^)(UIImage* image))completionHandler{
    if(self.tripImageData){
        UIImage* image = [UIImage imageWithData:self.tripImageData];
        completionHandler(image);
    }
    else{
        dispatch_queue_t imageLoadingQueue = dispatch_queue_create("queueForTrip", NULL);
        dispatch_async(imageLoadingQueue, ^{
            NSString * urlString = self.imageUrl;
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            self.tripImageData = imageData;
            UIImage* image = [UIImage imageWithData:imageData];

            completionHandler(image);
        });
    }
}

@end
