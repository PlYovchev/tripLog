//
//  TripAnnotation.h
//  TripLog
//
//  Created by plt3ch on 6/12/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TripAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) NSString *tripId;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
