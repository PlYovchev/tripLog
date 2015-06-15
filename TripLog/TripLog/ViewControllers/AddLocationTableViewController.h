//
//  AddLocationViewController.h
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AddLocationTableViewController : UITableViewController

@property (nonatomic) CLLocationCoordinate2D selectedLocationCoordinates;

@end
