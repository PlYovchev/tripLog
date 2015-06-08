//
//  LocationsTableViewCell.m
//  TripLog
//
//  Created by Student11 on 6/8/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LocationsTableViewCell.h"
@interface LocationsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *locationsImage;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelUser;


@end

@implementation LocationsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse{
    self.locationsImage = nil;
    self.labelLocation.text = @"";
    self.labelDate.text = @"";
    self.labelUser.text = @"";
}
/*
- (void)setLocationsCellForTrip(Trip*)trip{
 
 _trip = trip;
 self.locationsImage = _trip.image;
 self.labelLocation.text = _trip.location;
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm "];
 NSString *dateStr = [dateFormatter stringFromDate:_trip.date];
 self.labelDate.text = dateStr;
 self.labelUser.text = _trip.user;
}
*/
@end
