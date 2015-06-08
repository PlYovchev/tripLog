//
//  RegisterViewController.m
//  TripLog
//
//  Created by svetoslavpopov on 6/8/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhone;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
- (IBAction)userDidTapSignUpButton:(id)sender {
    [[TripLogWebServiceController sharedInstance] sendSignUpRequestToParseWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text andPhone:self.textFieldPhone.text];
}

@end
