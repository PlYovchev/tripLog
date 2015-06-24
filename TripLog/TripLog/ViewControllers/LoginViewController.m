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
@property (nonatomic) UIActivityIndicatorView *logginActivityIndocator;

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
                                  self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 215);

}

#pragma mark User input

- (IBAction)userDidTabOnButton:(id)sender {
    if ([(UIButton*)sender isEqual: self.buttonSignIn]) {
        // Perform validation of all text fields for empty string or string containing only white spaces
        if ([self validateFields]) {
            self.logginActivityIndocator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [self.view addSubview:self.logginActivityIndocator];
            self.logginActivityIndocator.color = [UIColor colorWithRed:0 green:255 blue:255 alpha:1];
            self.logginActivityIndocator.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 80) / 2), 25, 25);
            [self.logginActivityIndocator startAnimating];
            
            [[TripLogWebServiceController sharedInstance] sendSignInRequestToParseWithUsername:self.textFieldUsername.text andPassword:self.textFieldPassword.text];
        }
        // If the validation fails, show alert message
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid username or password!" message:@"" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
            
            [alertView show];
        }
    }
}

// Validate all text fields
-(BOOL)validateFields{
    if(![self validateFieldWithString:self.textFieldUsername.text] ||
       ![self validateFieldWithString:self.textFieldPassword.text]){
        return false;
    }
    
    return true;
}

// Validate field for empty string or for string containing only empty spaces
-(BOOL)validateFieldWithString: (NSString*)str{
    if([str isEqual:@""]){
        return false;
    }
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[str stringByTrimmingCharactersInSet: set] length] == 0)
    {
        return false;
    }
    
    return true;
}

// Detect when user focus is changed from the text field and hide the keyboard
-(void)textFieldDidEndEditing:(UITextField *)textField {
    // Keyboard will hide
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                       self.scrollView.frame.origin.y,
                                       self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height - 415);
}

// Hide keyboard when the user presses the return key
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFieldUsername || textField == self.textFieldPassword) {
        [textField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark TripLogWebServicesDelegate

-(void)userDidSignInSuccessfully:(BOOL)isSuccessful withUserId:(NSString *)userId andSessionToken:(NSString *)sessionToken{
    if (isSuccessful) {
        TripLogController* tripController = [TripLogController sharedInstance];
        [tripController logTheUserwithUserId:userId andSessionToken:sessionToken andSaveUserData:YES];
        
        // Set default user settings
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"autoLoginKey"];
        
        // Hide keyboard when login is successful
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textFieldPassword endEditing:YES];
            [self.textFieldUsername endEditing:YES];
            [self.logginActivityIndocator stopAnimating];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController* controller = [storyboard instantiateViewControllerWithIdentifier:@"TripTabViewController"];
            [self presentViewController:controller animated:YES completion:nil];
        });
        
        NSLog(@"Login successful!");
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.logginActivityIndocator stopAnimating];
            UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Login failed!" message:@"Please make sure that username or password are correct!" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
            
            [loginFailedAlert show];
        });
    }
}

@end
