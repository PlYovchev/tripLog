#import "ImageGalleryViewController.h"
#import "FXImageView.h"


@interface ImageGalleryViewController ()

@property (nonatomic, strong) Trip* selectedTrip;
@property (strong, nonatomic) NSMutableArray *imageURLs;
@property (nonatomic) BOOL directionIsLeft;
@property (nonatomic) NSInteger *previousIndex;
@property (nonatomic, strong) NSURL *url;

@end


@implementation ImageGalleryViewController

@synthesize carousel;

- (void)awakeFromNib
{
    //set up data
    //your carousel should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen
    
    self.selectedTrip = [[TripLogController sharedInstance] selectedTrip];
   
    [[TripLogWebServiceController sharedInstance] sendGetRequestForImagesWithTripId:self.selectedTrip.tripId andCompletitionHandler:^(NSDictionary *result) {
        
        self.imageURLs = [result objectForKey:@"results"];
    }];
    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [spinner setCenter:CGPointMake(screenRect.size.width / 2, screenRect.size.width /2)]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner];
    [
     carousel setHidden:YES];
    [spinner startAnimating];
    
    
    NSString *imageUrl;
    
    NSURLSessionConfiguration *sessionConfig;
    
    NSURLSession *session;
    
    for (int i = 0; i < self.imageURLs.count; i++) {
        imageUrl = [[[self.imageURLs objectAtIndex:index] valueForKey:@"Image"] valueForKey:@"url"];
        sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
        NSURLSessionDownloadTask *getImageTask = [session downloadTaskWithURL:[NSURL URLWithString:imageUrl]
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                UIImage *downloadedImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    
                                                                });
                                                            }];
        
        
        [getImageTask resume];
    }
    
   
    
    
    
    [self.carousel reloadData];
}

- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.directionIsLeft = YES;
    //configure carousel
    carousel.type = iCarouselTypeCoverFlow2;
    carousel.scrollSpeed = 0.5;
    carousel.autoscroll = -0.1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //free up memory by releasing subviews
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
    return 0;//[self.imageURLs count];
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
    //////////
   
    
    
    
    
    
    
    
//    ((FXImageView *)view).processedImage = downloadedImage;
//    [(FXImageView *)view setImage:downloadedImage];
    
    [carousel reloadItemAtIndex:index animated:YES];
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

- (void)carouselDidScroll:(iCarousel *)carousl{
    if (self.previousIndex == nil) {
        self.previousIndex = (NSInteger*)carousel.currentItemIndex;
    }
    if (self.previousIndex == nil) {
        self.previousIndex = (NSInteger*)carousel.currentItemIndex -1;
    }
    
    if (self.directionIsLeft == NO) {
        if (self.previousIndex > (NSInteger*)carousel.currentItemIndex) {
            carousel.autoscroll *= -1;
            self.directionIsLeft = YES;
            NSLog(@"Direction changed to RIGHT!");
        }
    }
    else{
        if (self.previousIndex < (NSInteger*)carousel.currentItemIndex) {
            carousel.autoscroll *= -1;
            self.directionIsLeft = NO;
            NSLog(@"Direction changed to LEFT!");
        }
    }
    
    if ((long)self.previousIndex != (long)carousel.currentItemIndex) {
        NSLog(@"%ld", (long)self.previousIndex);
        self.previousIndex = (NSInteger*)carousel.currentItemIndex;
        NSLog(@"%ld", (long)self.previousIndex);
    }
}

- (void)carousel:(iCarousel *)carousl didSelectItemAtIndex:(NSInteger)index{
    if (carousel.currentItemIndex == index) {
        carousel.autoscroll = 0;
    }
    
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
