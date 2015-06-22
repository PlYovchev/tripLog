//
//  RegisterViewController.m
//  TripLog
//
//  Created by svetoslavpopov on 6/8/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhone;
@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TripLogWebServiceController sharedInstance] setSignUpDelegate:self];
    [self setUILayoutStyles];
    
    // Add Register View Controller as observer to the default notification center to listen  for showing and hiding notifications of the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    // Set navigation bar styles
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24 green:248 blue:245 alpha:1];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UI Layout styles
-(void)setUILayoutStyles{
    // Initialize ContentView left constraint
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    // Initialize ContentView right constraint
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
    
    // Set text field holder views transparent background
    self.usernameView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.usernameView.layer.cornerRadius = 5;
    self.passwordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.passwordView.layer.cornerRadius = 5;
    self.phoneView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.phoneView.layer.cornerRadius = 5;
    
    // Set text fields placeholder's text color
    self.textFieldUsername.backgroundColor = [UIColor clearColor];
    [self.textFieldUsername setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.textFieldPassword.backgroundColor = [UIColor clearColor];
    [self.textFieldPassword setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.textFieldPhone.backgroundColor = [UIColor clearColor];
    [self.textFieldPhone setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    // Set corner radius
    self.signUpView.layer.cornerRadius = 15;

}

#pragma mark User input

- (IBAction)userDidTapSignUpButton:(id)sender {
    if ([self validateFields]) {
        
    }
    // Perform validation of all text fields for empty string or string containing only white spaces
    if ([self validateFields]) {
        [[TripLogWebServiceController sharedInstance] sendSignUpRequestToParseWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text andPhone:self.textFieldPhone.text];
    }
    // If the validation fails, show alert message
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid username, password or phone!" message:@"" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
            [alertView show];
        });
    }
}


// Validate all text fields
-(BOOL)validateFields{
    if(![self validateFieldWithString:self.textFieldUsername.text] ||
       ![self validateFieldWithString:self.textFieldPassword.text] ||
       ![self validateFieldWithString:self.textFieldPhone.text] ||
       ![self validatePhoneFieldWithStrng:self.textFieldPhone.text]){
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

// Validate phone field for non-numeric input
-(BOOL)validatePhoneFieldWithStrng: (NSString*)str{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:str];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    if (valid){
        return YES;
    }
    
    return NO;
}

// Set scrollview content when the keyboard is shown
- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Set scrollview content when keyboard is hidden
- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

// Select the active field
- (IBAction)textFieldDidBeginEditing:(UITextField *)sender
{
    self.activeField = sender;
}

// Unselect the active field
- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    self.activeField = nil;
}

// Hide keyboard when return button is tapped
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFieldUsername || textField == self.textFieldPassword || textField == self.textFieldPhone) {
        [textField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark TripLogWebServicesSignUpDelegate
-(void)userDidSignUpSuccessfully:(BOOL)isSuccessful{
    if (isSuccessful) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *registerFailedAlert = [[UIAlertView alloc] initWithTitle:@"Register failed!" message:@"Please make sure that username, password or phone are correct!" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
            
            [registerFailedAlert show];
        });
    }
}

@end
