//
//  AllTripsCollectionViewCell.m
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/12/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AllTripsCollectionViewCell.h"
@interface AllTripsCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelTripName;
@property (weak, nonatomic) IBOutlet UILabel *labelTripLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelCreator;
@property (weak, nonatomic) IBOutlet UILabel *labelRaiting;

@end


@implementation AllTripsCollectionViewCell
-(void)setCellTrip{
    _labelTripName.text=@"Trip Name";
    _labelTripLocation.text=@"Trip, Location";
    _labelCreator.text=@"Creator";
    _labelRaiting.text=@"7";
    
    _imageView.image = [UIImage imageNamed:@"default.jpg"];
}
@end
