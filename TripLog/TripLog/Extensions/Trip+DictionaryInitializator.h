//
//  Trip+DictionaryInitializator.h
//  TripLog
//
//  Created by plt3ch on 6/9/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "Trip.h"
#import "User.h"

@interface Trip (DictionaryInitializator)

-(void)setValuesForKeysWithTripDictionary:(NSDictionary*)tripDictionary andCreator:(User*)creator;

@end
