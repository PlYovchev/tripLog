//
//  LocationDetailsViewController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationDetailsViewController : UIViewController

@property (nonatomic, getter=isAtTripLocation) BOOL atTripLocation;
@property (nonatomic, getter=isLocationVisited) BOOL locationVisited;

@end
