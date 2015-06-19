//
//  WelcomeViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()<EASplashScreenDelegate>

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EASplashScreen *splashScreen = [[EASplashScreen alloc] initWithSplashScreenImage:[UIImage imageNamed:@"splashScreenImage2.jpg"] amountOfSlides:7];
    splashScreen.delegate = self;
    splashScreen.view.frame = self.view.bounds;
    [self.view addSubview:splashScreen.view];
}

- (void)splashScreenDidFinishTransisioning:(EASplashScreen *)splashController {
    NSLog(@"Splash screen is off the screen!");
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

@end
