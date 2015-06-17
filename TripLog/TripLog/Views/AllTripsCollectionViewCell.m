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

- (void)prepareForReuse{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.labelTripLocation.text = @"";
    self.labelCreator.text = @"";
    self.labelTripName.text = @"";
    self.labelRaiting.text = @"";
}


-(void)setCellforTrip:(Trip*)trip{
    _trip = trip;
    self.labelTripName.text=_trip.name;
    self.labelTripLocation.text=[NSString stringWithFormat:@"%@,%@",_trip.country, _trip.city];
    User *user = _trip.creator;
    
    self.labelCreator.text=[NSString stringWithFormat:@"%@",user.username];
    self.labelRaiting.text=[NSString stringWithFormat:@"%@",_trip.rating];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    [indicator setCenter:self.imageView.center];
    [self.contentView addSubview:indicator];
    

    
    dispatch_queue_t imageLoadingQueue = dispatch_queue_create("imageLoadingQueue", NULL);

        dispatch_async(imageLoadingQueue, ^{
        NSString * urlString = _trip.imageUrl;
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage * image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image=image;
            [indicator stopAnimating];
        });
    });
    
    

    
}
@end
