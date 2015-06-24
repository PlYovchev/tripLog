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
#import "TripLogCoreDataController.h"
#import "TripLogLocationController.h"
#import "Trip+DictionaryInitializator.h"
#import "AddImageViewController.h"
#import "ImageGalleryViewController.h"

@interface LocationDetailsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *tripImageView;
@property (weak, nonatomic) IBOutlet UITextView *tripInfoTextView;
@property (weak, nonatomic) IBOutlet UILabel *tripAuthorLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationButton;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIButton *yourGalleryButton;
@property (weak, nonatomic) IBOutlet ASStarRatingView *ratingView;

@end

@implementation LocationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomUIAppearanceStyles];
    
    TripLogController* tripController = [TripLogController sharedInstance];
    if([tripController.selectedTrip.tripId isEqualToString:tripController.enteredTripLocation.tripId]){
        self.atTripLocation = YES;
    }
    
    Trip* trip;
    if(!self.isAtTripLocation && self.isLocationVisited){
        trip = tripController.selectedTrip;
        self.yourGalleryButton.hidden = NO;
    }
    else if(!self.atTripLocation){
        trip = tripController.selectedTrip;
    }
    else {
        trip = tripController.enteredTripLocation;
        tripController.selectedTrip = tripController.enteredTripLocation;
        self.takePictureButton.hidden = NO;
        self.yourGalleryButton.hidden = NO;
    }
    
    // Set navigation title label custom layout styles
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.font = [UIFont boldSystemFontOfSize: 17.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    label.text = [NSString stringWithFormat:@"%@",trip.name];
    
    self.navigationItem.titleView = label;
    
    // Set raiting view custom layout styles
    self.ratingView.canEdit = NO;
    self.ratingView.maxRating = 10;
    self.ratingView.minAllowedRating = 1;
    self.ratingView.maxAllowedRating = 10;
    self.ratingView.rating = [trip.rating integerValue];
    [self.ratingView setUserInteractionEnabled:NO];
    
    // Set trip author
    self.tripAuthorLabel.text = [NSString stringWithFormat:@"Created by %@",trip.creator.username];
    self.tripAuthorLabel.numberOfLines = 2;
    self.tripInfoTextView.text = trip.tripDescription;

    // Download image from server and set trip image
    [trip requestImageDataWithCompletionHandler:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tripImageView.image = image;
        });
    }];
    
    [self setNotificationButtonTitleByObserveState];
}

#pragma mark UI appearance methods
-(void)setCustomUIAppearanceStyles{
    
    // Navigation bar appearance styles
    self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0 green:255 blue:198 alpha:1] forKey:NSForegroundColorAttributeName];
    
    // View appearance styles
    self.view.backgroundColor = [UIColor blackColor];
    
    // Tab bar appearance styles
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNotificationButtonTitleByObserveState{
    TripLogController* tripController = [TripLogController sharedInstance];
    Trip* trip = tripController.selectedTrip;
    
    if(![trip.isObserved boolValue]){
        [self.notificationButton setTitle:@"Notify me!" forState:UIControlStateNormal];
    }
    else{
        [self.notificationButton setTitle:@"Dont observe!" forState:UIControlStateNormal];
    }
}

- (IBAction)notificationButtonTapped:(id)sender {
    TripLogLocationController* locationController = [TripLogLocationController sharedInstance];
    TripLogController* tripController = [TripLogController sharedInstance];
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    
    Trip* trip = tripController.selectedTrip;
    
    if(![trip.isObserved boolValue]){
        [locationController startMonitorTripLocation:trip];
        trip.isObserved = @(YES);
    }
    else{
        [locationController stopMonitorTripLocation:trip];
        trip.isObserved = @(NO);
    }
    
    [dataController.mainManagedObjectContext save:nil];
    
    [self setNotificationButtonTitleByObserveState];
}

- (IBAction)yourGalleryButtonTapped:(id)sender {
    ImageGalleryViewController* imageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageGalleryViewController"];
    imageViewController.personalGallery = YES;
    [self.navigationController pushViewController:imageViewController animated:YES];
}

- (IBAction)takePictureTapped:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"gallerySegue"]) {
        NSLog(@"gallerySegue called!");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    AddImageViewController* imageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddImageViewController"];
    imageViewController.currentImage = image;
    
    [picker presentViewController:imageViewController animated:YES completion:nil];
}

@end
