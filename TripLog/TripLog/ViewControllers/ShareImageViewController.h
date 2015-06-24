//
//  ShareImageViewController.h
//  TripLog
//
//  Created by plt3ch on 6/24/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareImageViewController : UIViewController

@property (nonatomic) NSDictionary* imageProperties;
@property (nonatomic) UIImage* image;
@property (nonatomic, getter=isPublicImage) bool publicImage;

@end
