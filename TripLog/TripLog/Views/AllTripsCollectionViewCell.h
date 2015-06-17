//
//  AllTripsCollectionViewCell.h
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/12/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface AllTripsCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) Trip *trip;


-(void)setCellforTrip:(Trip*)trip;
@end
