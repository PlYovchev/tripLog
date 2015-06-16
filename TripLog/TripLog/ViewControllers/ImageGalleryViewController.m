#import "ImageGalleryViewController.h"
#import "FXImageView.h"


@interface ImageGalleryViewController ()

@property (nonatomic, strong) Trip* selectedTrip;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *imageURLs;
@property (nonatomic) BOOL directionIsLeft;
@property (nonatomic) NSInteger *previousIndex;
@property (nonatomic, strong) NSURL *url;

@end


@implementation ImageGalleryViewController

@synthesize carousel;

- (void)awakeFromNib
{
    self.selectedTrip = [[TripLogController sharedInstance] selectedTrip];
    
    // Set up the activity indicator
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [spinner setCenter:CGPointMake(screenRect.size.width / 2, screenRect.size.width /2)];
    
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
        [[TripLogWebServiceController sharedInstance] sendGetRequestForImagesWithTripId:self.selectedTrip.tripId andCompletitionHandler:^(NSDictionary *result) {
            
            self.imageURLs = [result objectForKey:@"results"];
            
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
            self.items = [NSMutableArray new];;
            
            for (int i = 0; i < URLs.count; i++) {
                NSData *myData = [NSData dataWithContentsOfURL:[URLs objectAtIndex:i]];
                UIImage *img = [UIImage imageWithData:myData];
                [self.items addObject:img];
            }
            
            [spinner stopAnimating];
            [spinner setHidden:YES];
            [carousel setHidden:NO];
            
            
            // Get back to the main thread and reload carousel data
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.carousel reloadData];
            });
        }];
    });
}

- (void)dealloc
{
    carousel.delegate = nil;
    carousel.dataSource = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set carousel configurations
    self.directionIsLeft = YES;
    carousel.type = iCarouselTypeCoverFlow2;
    carousel.scrollSpeed = 0.5;
    carousel.autoscroll = -0.1;
    
    [self.carousel reloadData];
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
    //return the total number of items in the carousel
    return [self.items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 250.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = NO;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        view = imageView;
    }
    
    //show placeholder
    ((FXImageView *)view).processedImage = [UIImage imageNamed:@"placeholder.png"];
    
    //set image with URL. FXImageView will then download and process the image
    [(FXImageView *)view setImage:[self.items objectAtIndex:index]];
    
    [self.carousel reloadItemAtIndex:index animated:YES];
    return view;
}

#pragma mark iCarousel delegate

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
    if (carousel.currentItemIndex == index) {
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
