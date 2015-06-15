//
//  User+DictionaryInitializator.m
//  TripLog
//
//  Created by plt3ch on 6/15/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "User+DictionaryInitializator.h"

#define ID_KEY @"objectId"
#define USERNAME_KEY @"username"

@implementation User (DictionaryInitializator)

-(void)setValuesForKeysWithUserInfoDictionary:(NSDictionary*)userInfoDictionary{
    self.userId = [userInfoDictionary objectForKey:ID_KEY];
    self.username = [userInfoDictionary objectForKey:USERNAME_KEY];
    
    NSLog(@"%@ %@", self.userId, self.username);
}

@end
