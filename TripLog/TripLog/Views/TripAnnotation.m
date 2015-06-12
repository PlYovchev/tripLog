//
//  TripAnnotation.m
//  TripLog
//
//  Created by plt3ch on 6/12/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripAnnotation.h"

@implementation TripAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate{
    _coordinate=coordinate;
    return self;
}

- (NSString *)subtitle{
    return nil;
}

- (NSString *)title{
    return nil;
}

@end
