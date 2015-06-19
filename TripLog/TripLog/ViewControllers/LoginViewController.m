//
//  LoginViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LoginViewController.h"

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
    
    // Set transparancy of the main containers
    self.loginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    self.passwordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];

    
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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)userDidTabOnButton:(id)sender {
    if ([(UIButton*)sender isEqual: self.buttonSignIn]) {
        [[TripLogWebServiceController sharedInstance] sendSignInRequestToParseWithUsername:self.textFieldUsername.text andPassword:self.textFieldPassword.text];
    }
    else{
        NSLog(@"b");
    }
}

#pragma mark TripLogWebServicesDelegate

-(void)userDidSignInSuccessfully:(BOOL)isSuccessful{
    if (isSuccessful) {
        NSLog(@"Login successful!");
    }
    else{
        NSLog(@"Login failed!");
    }
}

@end
