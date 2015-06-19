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
    CLLocation* location = [[CLLocation alloc] initWithLatitude:self.selectedLocationCoordinates.latitude
                                                      longitude:self.selectedLocationCoordinates.longitude];
    [self findCityAndCountry:location];
    
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
    }
    
    NSString* tripName = self.nameTextField.text;
    NSString* tripCity = self.cityTextField.text;
    NSString* tripCountry = self.countryTextField.text;
    NSNumber* isPrivate = [NSNumber numberWithBool:!self.isPublicSwitch.on];
    NSString* tripDescription = self.tripDescriptionTextView.text;
    NSNumber* tripLatitude = [NSNumber numberWithDouble:self.selectedLocationCoordinates.latitude];
    NSNumber* tripLongitude = [NSNumber numberWithDouble:self.selectedLocationCoordinates.longitude];
    
    NSMutableDictionary* tripProperties = [NSMutableDictionary dictionary];
    [tripProperties setObject:tripName forKey:NAME_KEY];
    [tripProperties setObject:tripCity forKey:CITY_KEY];
    [tripProperties setObject:tripCountry forKey:COUNTRY_KEY];
    [tripProperties setObject:isPrivate forKey:IS_PRIVATE_KEY];
    [tripProperties setObject:tripDescription forKey:DESCRIPTION_KEY];
    
    NSMutableDictionary* tripLocation = [NSMutableDictionary dictionary];
    [tripLocation setObject:tripLatitude forKey:LATITUDE_KEY];
    [tripLocation setObject:tripLongitude forKey:LONGITUDE_KEY];
    [tripProperties setObject:tripLocation forKey:LOCATION_KEY];
    
    TripLogController* tripController = [TripLogController sharedInstance];
    [tripController saveTrip:tripProperties];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)validateFields{
    if([self.nameTextField.text isEmpty]){
        return false;
    }
    
    return true;
}

- (void)findCityAndCountry:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.cityTextField.text= placemark.locality;
            self.countryTextField.text = placemark.country;
            self.cityTextField.enabled = NO;
            self.countryTextField.enabled = NO;
        }
    }];
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
