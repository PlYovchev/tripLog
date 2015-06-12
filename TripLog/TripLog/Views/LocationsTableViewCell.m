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
@property (weak, nonatomic) IBOutlet UILabel *labelCreator;
@property (weak, nonatomic) IBOutlet UILabel *labelTripName;



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
    self.labelCreator.text = @"";
    self.labelTripName.text = @"";
}

- (void)setLocationsCellForTrip:(Trip*)trip withURL:(NSString *)url{
    
    _trip = trip;
    User *user = _trip.creator;
    self.labelLocation.text = [NSString stringWithFormat:@"%@,%@",_trip.country, _trip.city];
    self.labelCreator.text = [NSString stringWithFormat:@"%@", user.username];
    self.labelTripName.text = _trip.name;
    NSURL *imageURL = [NSURL URLWithString:url];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session =  [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:imageURL
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                self.locationsImage.image = [UIImage imageWithData:data];
                                            });
                                        }];
    
    [task resume];

}

@end
