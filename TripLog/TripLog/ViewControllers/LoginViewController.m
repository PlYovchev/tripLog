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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        [[TripLogWebServiceController sharedInstance] sendSignInRequestToParse:self.textFieldUsername.text andWithPassword:self.textFieldPassword.text];
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
