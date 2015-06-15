//
//  ImageGalleryViewController.h
//  TripLog
//
//  Created by svetoslavpopov on 6/12/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "TripLogController.h"
#import "TripLogWebServiceController.h"


@interface ImageGalleryViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet iCarousel *carousel;

@end
