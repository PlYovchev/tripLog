//
//  ShareImageViewController.m
//  TripLog
//
//  Created by plt3ch on 6/24/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "ShareImageViewController.h"
#import "TripLogWebServiceController.h"

@interface ShareImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIBarButtonItem* shareButton;

@end

@implementation ShareImageViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.imageView.image = self.image;
    
    bool isPublic = [[self.imageProperties objectForKey:@"IsPublic"] boolValue];
    if(!self.isPublicImage && !isPublic){
        self.shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped)];
        self.navigationItem.rightBarButtonItem = self.shareButton;
    }
    self.navigationItem.title = @"Review image";
}

-(void)shareButtonTapped{
    NSString* imageId = [self.imageProperties objectForKey:@"objectId"];
    
    UIActivityIndicatorView* logginActivityIndocator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:logginActivityIndocator];
    logginActivityIndocator.color = [UIColor colorWithRed:0 green:255 blue:255 alpha:1];
    logginActivityIndocator.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 80) / 2), 25, 25);
    [logginActivityIndocator startAnimating];
    
    TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
    [webController sendPutRequestForShareImageWithImageId:imageId andCompletitionHandler:^(NSDictionary *result, NSInteger status) {
        NSString* title;
        NSString* body;
        bool isSuccessful;
        if(status == 200){
            title = @"Success!";
            body = @"The image was shared!";
            isSuccessful = YES;
        }
        else{
            title = @"Fail!";
            body = @"The image wasn't shared!";
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
                                           [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
                                           [self.navigationItem.rightBarButtonItem setEnabled:NO];
                                       }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }];
}

@end
