//
//  AddLocationViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AddLocationTableViewController.h"
#import "NSString+Validation.h"
#import "Trip+DictionaryInitializator.h"
#import "TripLogController.h"

@interface AddLocationTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isPublicSwitch;
@property (weak, nonatomic) IBOutlet UITextView *tripDescriptionTextView;

@end

@implementation AddLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:self.selectedLocationCoordinates.latitude longitude:self.selectedLocationCoordinates.longitude];
    [self findCityAndCountry:location];
    
    // Initialize save button
    UIBarButtonItem* saveBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveTheTrip)];
    self.navigationItem.rightBarButtonItem = saveBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveTheTrip{
    if(![self validateFields]){
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Incorrect or missing values!"
                                                                            message:@"Some of the fields have incorrect data!"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    // Initialize properties
    NSString* tripId = [[NSUUID UUID] UUIDString];
    NSString* tripName = self.nameTextField.text;
    NSString* tripCity = self.cityTextField.text;
    NSString* tripCountry = self.countryTextField.text;
    NSNumber* isPrivate = [NSNumber numberWithBool:!self.isPublicSwitch.on];
    NSString* tripDescription = self.tripDescriptionTextView.text;
    NSNumber* tripLatitude = [NSNumber numberWithDouble:self.selectedLocationCoordinates.latitude];
    NSNumber* tripLongitude = [NSNumber numberWithDouble:self.selectedLocationCoordinates.longitude];
    
    // Set trip properties
    NSMutableDictionary* tripProperties = [NSMutableDictionary dictionary];
    [tripProperties setObject:tripId forKey:ID_KEY];
    [tripProperties setObject:tripName forKey:NAME_KEY];
    [tripProperties setObject:tripCity forKey:CITY_KEY];
    [tripProperties setObject:tripCountry forKey:COUNTRY_KEY];
    [tripProperties setObject:isPrivate forKey:IS_PRIVATE_KEY];
    [tripProperties setObject:tripDescription forKey:DESCRIPTION_KEY];
    [tripProperties setObject:@(NO) forKey:IS_SYNCHRONIZED_KEY];
    
    // Set trip location
    NSMutableDictionary* tripLocation = [NSMutableDictionary dictionary];
    [tripLocation setObject:tripLatitude forKey:LATITUDE_KEY];
    [tripLocation setObject:tripLongitude forKey:LONGITUDE_KEY];
    [tripProperties setObject:tripLocation forKey:LOCATION_KEY];
    
    // Set trip
    TripLogController* tripController = [TripLogController sharedInstance];
    [tripController saveTrip:tripProperties];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Validate fields for empty string or only white spaces containing string
-(BOOL)validateFields{
    if([self.nameTextField.text isEmpty]){
        return false;
    }
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[self.nameTextField.text stringByTrimmingCharactersInSet: set] length] == 0)
    {
        return false;
    }
    
    return true;
}

- (void)findCityAndCountry:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        // If some error occures on the console is printed error message with description
        if (error) {
            NSLog(@"Error %@", error.description);
        }
        // Set text field values if no errors are recieved
        else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.cityTextField.text= placemark.locality;
            self.countryTextField.text = placemark.country;
            self.cityTextField.enabled = NO;
            self.countryTextField.enabled = NO;
        }
    }];
}

@end
