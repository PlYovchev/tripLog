//
//  AllTripsSearchViewController.h
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/16/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripLogCoreDataController.h"
typedef void (^SearchPredicatesApplied)();

@interface AllTripsSearchViewController : UIViewController

@property (copy) SearchPredicatesApplied searchPredicatesApplied;

@end
