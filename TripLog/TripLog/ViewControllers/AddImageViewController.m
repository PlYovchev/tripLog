//
//  AddImageViewController.m
//  TripLog
//
//  Created by plt3ch on 6/24/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AddImageViewController.h"
#import "TripLogWebServiceController.h"
#import "TripLogController.h"

@interface AddImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation AddImageViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.imageView.image = self.currentImage;
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonTapped:(id)sender {
    TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
    TripLogController* tripController = [TripLogController sharedInstance];
    
    UIActivityIndicatorView* logginActivityIndocator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:logginActivityIndocator];
    logginActivityIndocator.color = [UIColor colorWithRed:0 green:255 blue:255 alpha:1];
    logginActivityIndocator.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 80) / 2), 25, 25);
    [logginActivityIndocator startAnimating];
    NSData* imageData = UIImageJPEGRepresentation(self.currentImage, 1);
    [webController sendPostRequestForImageWithData:imageData usedId:tripController.loggedUser.userId tripId:tripController.enteredTripLocation.tripId isPublic:@(NO) andCompletitionHandler:^(NSDictionary *result, NSInteger status) {
        
        NSString* title;
        NSString* body;
        bool isSuccessful;
        if(status == 201){
            title = @"Success!";
            body = @"The image was saved!";
            isSuccessful = YES;
        }
        else{
            title = @"Fail!";
            body = @"The image wasn't saved!";
            isSuccessful = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [logginActivityIndocator stopAnimating];
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:body
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           [self dismissViewControllerAnimated:nil completion:^{
                                               if(isSuccessful){
                                                   UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                                   while (topController.presentedViewController) {
                                                       topController = topController.presentedViewController;
                                                   }
                                               
                                                   [topController dismissViewControllerAnimated:YES completion:nil];
                                               }
                                           }];
                                       }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }];
}

@end
