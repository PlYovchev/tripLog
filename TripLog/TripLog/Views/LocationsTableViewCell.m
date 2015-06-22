//
//  LocationsTableViewCell.m
//  TripLog
//
//  Created by Student11 on 6/8/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LocationsTableViewCell.h"
#import "ASStarRatingView.h"

@interface LocationsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *tripImageView;
@property (weak, nonatomic) IBOutlet UILabel *labelTripName;
@property (weak, nonatomic) IBOutlet UILabel *labelTripLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelCreator;
@property (weak, nonatomic) IBOutlet ASStarRatingView *starRatingView;

@end

@implementation LocationsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.contentView.layer setBorderWidth:2.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.tripImageView.image = nil;
    self.labelTripLocation.text = @"";
    self.labelCreator.text = @"";
    self.labelTripName.text = @"";
    self.starRatingView.rating = 0;
}


-(void)setCellforTrip:(Trip*)trip{
    _trip = trip;
    User *user = _trip.creator;
    
    self.labelTripName.text=_trip.name;
    self.labelTripLocation.text=[NSString stringWithFormat:@"%@,%@",_trip.country, _trip.city];
    self.labelCreator.text=[NSString stringWithFormat:@"%@",user.username];
    self.starRatingView.canEdit = NO;
    self.starRatingView.maxRating = 10;
    self.starRatingView.minAllowedRating = 1;
    self.starRatingView.maxAllowedRating = 10;
    if(!trip.rating){
        self.starRatingView.rating = 0;
    }
    else{
        self.starRatingView.rating = [trip.rating integerValue];
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    [indicator setCenter:self.imageView.center];
    [self.contentView addSubview:indicator];
    
    //self.labelsView.clipsToBounds = YES;
//    CALayer *rightBorder = [CALayer layer];
//    rightBorder.borderColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1].CGColor;
//    rightBorder.borderWidth = 2;
//    rightBorder.frame = CGRectMake(0, -2, self.imageView.frame.size.width + 130, 43);
    //[self.labelsView.layer addSublayer:rightBorder];
    
    //self.backgroundColor = [UIColor blackColor];
    
    dispatch_queue_t imageLoadingQueue = dispatch_queue_create("imageLoadingQueue", NULL);
    
    dispatch_async(imageLoadingQueue, ^{
        NSString * urlString = _trip.imageUrl;
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage * image = [UIImage imageWithData:imageData];
        _trip.tripImageData = imageData;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image==nil){
                self.tripImageView.image = [UIImage imageNamed:@"placeholder.png"];
            }else{
                self.tripImageView.image=image;
                
            }
            [indicator stopAnimating];
        });
    });
    
    
    
    
}

@end
