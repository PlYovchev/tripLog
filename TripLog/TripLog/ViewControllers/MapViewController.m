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
#import "TripLogLocationController.h"
#import "TripLogController.h"
#import "AddLocationTableViewController.h"

#define SPAN_LATITUDE_DELTA 0.0395
#define SPAN_LONGITUDE_DELTA 0.0395

@interface MapViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the color of the View Controller title
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor colorWithRed:0 green:255 blue:198 alpha:1],
                                               NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [TripLogLocationController sharedInstance];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressToGetLocation:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.mapView addGestureRecognizer:lpgr];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(placePinsInRadius:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self placePinsInRadius:0];
    [self setMapViewInitialZoomLevel];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self removeManagedObjectContextSaveNotificationObserver];
}

-(void)dealloc{
    [self removeManagedObjectContextSaveNotificationObserver];
}

-(void)removeManagedObjectContextSaveNotificationObserver{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

-(void)setMapViewInitialZoomLevel{
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.centerCoordinate.latitude;
    region.center.longitude = self.mapView.centerCoordinate.longitude;
    region.span.latitudeDelta = SPAN_LATITUDE_DELTA;
    region.span.longitudeDelta = SPAN_LONGITUDE_DELTA;
    
    [self.mapView setRegion:region animated:YES];
}

-(void)placePinsInRadius:(CGFloat)radius{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    NSArray* trips = [dataController trips];
    for (Trip* trip in trips) {
        CGFloat latitude = [trip.latitude doubleValue];
        CGFloat longitude = [trip.longitude doubleValue];
        
        if(latitude != 0 || longitude != 0){
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
            TripAnnotation* annotation = [[TripAnnotation alloc] init];
            annotation.coordinate = coord;
            annotation.title = trip.name;
            annotation.subtitle = trip.tripDescription;
            annotation.tripId = trip.tripId;
            [self.mapView addAnnotation:annotation];
        }
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region;
    region.center.latitude = userLocation.coordinate.latitude;
    region.center.longitude = userLocation.coordinate.longitude;
    region.span.latitudeDelta = self.mapView.region.span.latitudeDelta;
    region.span.longitudeDelta = self.mapView.region.span.longitudeDelta;
    
    [self.mapView setRegion:region animated:YES];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[TripAnnotation class]])
    {
        TripAnnotation* tripAnnotation = (TripAnnotation*)annotation;
        
        TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
        NSArray* tripsWithId = [dataController tripsWithId:tripAnnotation.tripId inContext:dataController.mainManagedObjectContext];
        if([tripsWithId count] == 0){
            return;
        }
        
        Trip* trip = [tripsWithId objectAtIndex:0];
        TripLogController* tripManager = [TripLogController sharedInstance];
        tripManager.selectedTrip = trip;
        UIViewController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
        [self.navigationController pushViewController:detailsController animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[TripAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.pinColor = MKPinAnnotationColorGreen;

            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
        } else {
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    
    return nil;
}

- (void)longpressToGetLocation:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D location = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Add new location!"
                                                                             message:@"Do you want to add new trip location here?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                   AddLocationTableViewController* addLocationController = [mainStoryboard instantiateViewControllerWithIdentifier:@"AddLocationController"];
                                   addLocationController.selectedLocationCoordinates = location;
    
                                   [self.navigationController pushViewController:addLocationController animated:YES];
                            }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
