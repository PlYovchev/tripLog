#import "ImageGalleryViewController.h"
#import "FXImageView.h"
#import "TripLogController.h"
#import "ShareImageViewController.h"

@interface ImageGalleryViewController ()

@property (nonatomic, strong) Trip* selectedTrip;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *imageURLs;
@property (nonatomic) BOOL directionIsLeft;
@property (nonatomic) NSInteger *previousIndex;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) NSUInteger currentSelectedIndex;
@property (nonatomic) BOOL firstClickDone;

@end


@implementation ImageGalleryViewController

@synthesize carousel;

- (void)dealloc
{
    carousel.delegate = nil;
    carousel.dataSource = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // Set carousel configurations
    self.directionIsLeft = YES;
    carousel.type = iCarouselTypeCoverFlow2;
    carousel.scrollSpeed = 0.5;
    carousel.autoscroll = -0.1;
    
    [self.carousel reloadData];
    
    self.selectedTrip = [[TripLogController sharedInstance] selectedTrip];
    
    // Set up the activity indicator
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [spinner setCenter:CGPointMake(screenRect.size.width / 2, screenRect.size.width /2)];
    spinner.color = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    
    // Add the activity indicator to the view
    [self.view addSubview:spinner];
    
    // Hide the carousel view and start animationg the activity indicator
    [self.carousel setHidden:YES];
    [spinner startAnimating];
    
    /*!
     * Perform download of all images in background thread.
     * Every image is downloaded synchronously so when every
     * image is downloaded the activity indicator will be hidden
     * and the carousel view will be shown.
     */
    dispatch_queue_t queue = dispatch_queue_create("downloadQueue", NULL);
    dispatch_async(queue, ^{
        void (^onImageDownload)(NSDictionary *result) = ^(NSDictionary *result) {
            
            self.imageURLs = [result objectForKey:@"results"];
            
            if ([self.imageURLs count]) {
                NSMutableArray *URLs = [NSMutableArray array];
                for (NSDictionary *path in self.imageURLs)
                {
                    NSURL *URL = [NSURL URLWithString:[[path valueForKey:@"Image"] valueForKey:@"url" ]];
                    if (URL)
                    {
                        [URLs addObject:URL];
                    }
                    else
                    {
                        NSLog(@"'%@' is not a valid URL", path);
                    }
                }
                self.images = [NSMutableArray new];;
                
                for (int i = 0; i < URLs.count; i++) {
                    NSData *myData = [NSData dataWithContentsOfURL:[URLs objectAtIndex:i]];
                    UIImage *img = [UIImage imageWithData:myData];
                    [self.images addObject:img];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [spinner setHidden:YES];
                    [carousel setHidden:NO];
                });
            }
            
            // Get back to the main thread and reload carousel data
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                [spinner setHidden:YES];
                [carousel setHidden:NO];
                [self.carousel reloadData];
            });
        };
        
        if(!self.isPersonalGallery){
            [[TripLogWebServiceController sharedInstance] sendGetRequestForImagesWithTripId:self.selectedTrip.tripId andCompletitionHandler:onImageDownload];
        }
        else{
            TripLogController* tripController = [TripLogController sharedInstance];
            [[TripLogWebServiceController sharedInstance] sendGetRequestForImagesWithTripId:self.selectedTrip.tripId userId:tripController.loggedUser.userId andCompletitionHandler:onImageDownload];
        }
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Free up memory by releasing subviews
    self.carousel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    /*!
     * Return the total number of images in the carousel.
     * If the number of images is equal to zero, the method returns zero and
     * the carousel will display placeholder
    !*/
    if ([self.images count] == 0) {
        return 1;
    }
    
    return [self.images count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 325.0f, 325.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = NO;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        view = imageView;
    }
    
    // Show placeholder
    [(FXImageView *)view setImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // Checks if the images count is greater than ZERO. If the count is equal to ZERO, the carousel will display single placeholder image.
    if ([self.images count] > 0) {
        [(FXImageView *)view setImage:[self.images objectAtIndex:index]];
    }
    
    
    [self.carousel reloadItemAtIndex:index animated:YES];
    return view;
}

#pragma mark iCarousel delegate
// Set additional options for the carousel
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    switch (option) {
        case iCarouselOptionWrap:
            return NO;
            break;
            
        default:
            return value;
            break;
    }
}

- (void)carousel:(iCarousel *)carousl didSelectItemAtIndex:(NSInteger)index{
    // When the user taps on the middle image, the autoscroll will be disabled and the animation will stop.
    if(self.firstClickDone && self.currentSelectedIndex == index && carousel.currentItemIndex == index){
        NSLog(@"Second click for index %ld done!", (long)index);
        FXImageView* fxImageView = (FXImageView*)carousel.currentItemView;
        
        ShareImageViewController* shareViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareImageViewController"];
        shareViewController.image = fxImageView.image;
        shareViewController.imageProperties = self.imageURLs[index];
        if(!self.isPersonalGallery){
            shareViewController.publicImage = YES;
        }
        
        [self.navigationController pushViewController:shareViewController animated:YES];
        
        self.firstClickDone = NO;
        return;
    }
    
    if (carousel.currentItemIndex == index) {
        self.currentSelectedIndex = index;
        self.firstClickDone = YES;
        carousel.autoscroll = 0;
    }
    
    // When the user taps on the user taps on the next or previous image, the autoscroll
    // will be enabled and the animation will run.
    if ((NSInteger*)carousel.currentItemIndex != nil) {
        if ((NSInteger*)index > (NSInteger*)carousel.currentItemIndex || (carousel.currentItemIndex == carousel.numberOfItems - 1 && index == 0)) {
            carousel.autoscroll = -0.1;
            self.directionIsLeft = NO;
        }
        else if((NSInteger*)index < (NSInteger*)carousel.currentItemIndex || (index == carousel.numberOfItems - 1 && carousel.currentItemIndex == 0)){
            carousel.autoscroll = 0.1;
            self.directionIsLeft = YES;
        }
    }
    else{
        carousel.autoscroll *= -1;
        self.directionIsLeft = YES;
    }
    
    NSLog(@"%ld", (long)index);
    self.previousIndex = (NSInteger*)index;
}

@end
