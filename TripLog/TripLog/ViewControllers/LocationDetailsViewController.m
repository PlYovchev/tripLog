//
//  LocationDetailsViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "ASStarRatingView.h"
#import "TripLogController.h"

@interface LocationDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tripImageView;
@property (weak, nonatomic) IBOutlet ASStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UITextView *tripInfoTextView;
@property (weak, nonatomic) IBOutlet UILabel *tripAuthorLabel;

@end

@implementation LocationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TripLogController* tripController = [TripLogController sharedInstance];
    Trip* trip = tripController.selectedTrip;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.font = [UIFont boldSystemFontOfSize: 17.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    label.text = [NSString stringWithFormat:@"%@",trip.name];
    
    self.navigationItem.titleView = label;
    
    self.ratingView.canEdit = YES;
    self.ratingView.maxRating = 10;
    self.ratingView.minAllowedRating = 1;
    self.ratingView.maxAllowedRating = 10;
    self.ratingView.rating = [trip.rating integerValue];
    [self.ratingView setUserInteractionEnabled:NO];
    
    self.tripAuthorLabel.text = [NSString stringWithFormat:@"Created by %@",trip.creator.username];
    self.tripAuthorLabel.numberOfLines = 2;
    self.tripInfoTextView.text = trip.tripDescription;
    self.tripImageView.image = [UIImage imageWithData:trip.tripImageData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"gallerySegue"]) {
        NSLog(@"gallerySegue called!");
    }
}

@end
