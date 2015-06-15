//
//  User+DictionaryInitializator.h
//  TripLog
//
//  Created by plt3ch on 6/15/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "User.h"

@interface User (DictionaryInitializator)

-(void)setValuesForKeysWithUserInfoDictionary:(NSDictionary*)userInfoDictionary;

@end
