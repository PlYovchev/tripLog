//
//  Trip+DictionaryInitializator.h
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Trip.h"
#import "User.h"

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
#define IMAGE_URL_KEY @"imageUrl"
#define IS_PRIVATE_KEY @"IsPrivate"
#define IS_SYNCHRONIZED_KEY @"isSynchronized"

@interface Trip (DictionaryInitializator)

-(void)setValuesForKeysWithTripDictionary:(NSDictionary*)tripDictionary andCreator:(User*)creator;
-(void)requestImageDataWithCompletionHandler:(void (^)(UIImage* image))completionHandler;

@end
