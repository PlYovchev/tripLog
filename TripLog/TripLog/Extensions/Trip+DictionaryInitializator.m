//
//  Trip+DictionaryInitializator.m
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "Trip+DictionaryInitializator.h"
#import "TripLogCoreDataController.h"

#define ID_KEY @"objectId"
#define NAME_KEY @"Name"
#define CITY_KEY @"City"
#define COUNTRY_KEY @"Country"
#define DESCRIPTION_KEY @"Description"
#define LOCATION_KEY @"Location"
#define LATITUDE_KEY @"latitude"
#define LONGITUDE_KEY @"longitude"
#define RATING_KEY @"Raiting"
#define CREATOR_KEY @"User"

@implementation Trip (DictionaryInitializator)

-(void)setValuesForKeysWithTripDictionary:(NSDictionary*)tripDictionary andCreator:(User*)creator{
    self.tripId = [tripDictionary objectForKey:ID_KEY];
    self.name = [tripDictionary objectForKey:NAME_KEY];
    self.city = [tripDictionary objectForKey:CITY_KEY];
    self.country = [tripDictionary objectForKey:COUNTRY_KEY];
    self.rating = [tripDictionary objectForKey:RATING_KEY];
    self.tripDescription = [tripDictionary objectForKeyedSubscript:DESCRIPTION_KEY];
    self.creator = creator;
    
    NSDictionary* location = [tripDictionary objectForKey:LOCATION_KEY];
    self.latitude = [location objectForKey:LATITUDE_KEY];
    self.longitude = [location objectForKey:LONGITUDE_KEY];
    
    NSLog(@"%@ %@ %@ %@ %@ %@", self.tripId, self.name, self.rating, self.latitude, self.longitude, self.creator.userId);
}

@end
