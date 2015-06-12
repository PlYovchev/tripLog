//
//  LocationsTableViewCell.h
//  TripLog
//
//  Created by Student11 on 6/8/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "User.h"



@interface LocationsTableViewCell : UITableViewCell
@property (nonatomic, strong) Trip *trip;
- (void)setLocationsCellForTrip:(Trip*)trip withURL:(NSString *)url;
@end
