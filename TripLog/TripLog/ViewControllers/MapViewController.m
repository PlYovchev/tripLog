//
//  MapViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

@import MapKit;

#import "MapViewController.h"
#import "TripLogCoreDataController.h"
#import "Trip.h"
#import "TripAnnotation.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self placePinsInRadius:0];
}

-(void)placePinsInRadius:(CGFloat)radius{
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    NSArray* trips = [dataController trips];
    for (Trip* trip in trips) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([trip.latitude doubleValue], [trip.longitude doubleValue]);
        TripAnnotation* annotation = [[TripAnnotation alloc] initWithCoordinate:coord];
        [self.mapView addAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    NSLog(@"annotation was selected!");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
