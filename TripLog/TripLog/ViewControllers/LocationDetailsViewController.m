//
//  LocationDetailsViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "ASStarRatingView.h"

@interface LocationDetailsViewController ()

@property (weak, nonatomic) IBOutlet ASStarRatingView *ratingView;

@end

@implementation LocationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ratingView.canEdit = YES;
    self.ratingView.maxRating = 8;
    self.ratingView.minAllowedRating = 4;
    self.ratingView.maxAllowedRating = 6;
    self.ratingView.rating = 5;
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
