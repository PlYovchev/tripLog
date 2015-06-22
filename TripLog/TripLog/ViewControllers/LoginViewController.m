//
//  LoginViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LoginViewController.h"
#import "TripLogController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set status bar white color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set navigation bar hidden without animation for the first load of the view
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    // Set transparancy of the main containers
    self.loginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    self.loginView.layer.cornerRadius = 5;
    self.passwordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    self.passwordView.layer.cornerRadius = 5;

    
    // Set transparancy of the text fields
    self.textFieldUsername.backgroundColor = [UIColor clearColor];
    self.textFieldPassword.backgroundColor = [UIColor clearColor];
   
    // Set text field placeholders
    [self.textFieldUsername setValue:[UIColor grayColor]
                          forKeyPath:@"_placeholderLabel.textColor"];
    [self.textFieldPassword setValue:[UIColor grayColor]
                          forKeyPath:@"_placeholderLabel.textColor"];

    self.buttonView.layer.cornerRadius = 15;
    
    
    [[TripLogWebServiceController sharedInstance] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    // Set navigation bar hidden animation
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    // Keyboard becomes visible
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                  self.scrollView.frame.origin.y,
                                  self.scrollView.frame.size.width, 50);   //resize
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    // Keyboard will hide
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                  self.scrollView.frame.origin.y,
                                  self.scrollView.frame.size.width,
                                  self.scrollView.frame.size.height + 215 - 50); //resize
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFieldUsername || textField == self.textFieldPassword) {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (IBAction)userDidTabOnButton:(id)sender {
    if ([(UIButton*)sender isEqual: self.buttonSignIn]) {
        [[TripLogWebServiceController sharedInstance] sendSignInRequestToParseWithUsername:self.textFieldUsername.text andPassword:self.textFieldPassword.text];
    }
}

#pragma mark TripLogWebServicesDelegate

-(void)userDidSignInSuccessfully:(BOOL)isSuccessful withUserId:(NSString *)userId andSessionToken:(NSString *)sessionToken{
    if (isSuccessful) {
        TripLogController* tripController = [TripLogController sharedInstance];
        [tripController logTheUserwithUserId:userId andSessionToken:sessionToken andSaveUserData:YES];
        
        // Set default user settings
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"autoLoginKey"];
        [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:self];
        
        // Hide keyboard when login is successful
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textFieldPassword endEditing:YES];
            [self.textFieldUsername endEditing:YES];
        });
        
        NSLog(@"Login successful!");
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Login failed!" message:@"Please make sure that username or password are correct!" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
            
            [loginFailedAlert show];
        });
    }
}

@end
