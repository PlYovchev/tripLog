//
//  TripLogWebServiceController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripLogWebServiceController.h"

@implementation TripLogWebServiceController

static TripLogWebServiceController* webController;

+(id)sharedInstance{
    @synchronized(self){
        if (!webController) {
            webController = [[TripLogWebServiceController alloc] init];
        }
    }
    
    return webController;
}

-(instancetype)init{
    if(webController){
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    }
    else{
        self = [super init];
        if(self){
            webController = self;
        }
    }
    
    return webController;
}

-(void)sendLoginRequestToParse:(NSString*)username andWithPassword:(NSString*)pass{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://httpbin.org/get?show_env=1"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
        
        NSLog(@"%ld", (long)[resp statusCode]);
    }];
    [dataTask resume];
    
}

-(void)sendRequestWithUrlParams:(NSDictionary *)urlParams andHeaders: (NSDictionary*)headers{
}
@end
