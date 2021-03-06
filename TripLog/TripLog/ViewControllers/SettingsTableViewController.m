//
//  SettingsTableViewController.m
//  TripLog
//
//  Created by Student17 on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AppDelegate.h"
#import "TripLogController.h"
#import "TripLogLocationController.h"

@interface SettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *swithAutoSubmitToServer;
@property (weak, nonatomic) IBOutlet UISwitch *switchAutoLogin;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Set auto submit switch value at loading of the view
    if ([userDefaults objectForKey:@"autoSubmitKey"]) {
        [self.swithAutoSubmitToServer setOn:YES animated:YES];
    }
    else{
        [self.swithAutoSubmitToServer setOn:NO animated:YES];
    }
    
    // Set auto login swtich value at loading of the view
    if ([userDefaults objectForKey:@"autoLoginKey"]) {
        [self.switchAutoLogin setOn:YES animated:YES];
    }
    else{
        [self.switchAutoLogin setOn:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchValueDidChange:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Set user defaults value for auto submit
    if (self.swithAutoSubmitToServer == sender) {
        TripLogController* tripController = [TripLogController sharedInstance];
        tripController.autoSubmitTripToServer = self.swithAutoSubmitToServer.isOn;
        [userDefaults setBool:self.swithAutoSubmitToServer.isOn forKey:@"autoSubmitKey"];
        [userDefaults synchronize];
    }
    
    // Set user defaults value for auto login
    else if(self.switchAutoLogin == sender){
        [userDefaults setBool:self.switchAutoLogin.isOn forKey:@"autoLoginKey"];
        [userDefaults synchronize];
    }
}

- (IBAction)buttonActionTapped:(id)sender {
    if (sender == self.logoutButton) {
        // Sets user defaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"hasUserDataKey"];
        [userDefaults setBool:YES forKey:@"autoLoginKey"];
        [userDefaults synchronize];
        
        TripLogController* tripController = [TripLogController sharedInstance];
        [tripController stopRefreshTimer];
        
        TripLogLocationController* locationController = [TripLogLocationController sharedInstance];
        [locationController stopMonitorAllTripLocations];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = controller;
        [appDelegate.window makeKeyAndVisible];;
    }
}

@end
