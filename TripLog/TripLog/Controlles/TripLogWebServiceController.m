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

-(void)sendSignInRequestToParseWithUsername:(NSString*)username andPassword:(NSString*)password{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *headers = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
                              @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo",
                              @"X-Parse-Revocable-Session":@"1"};
    
    [configuration setHTTPAdditionalHeaders:headers];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.parse.com/1/login?username=%@&password=%@", username, password]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            User *current = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.loggedUser = current;
            
            [self.delegate userDidSignInSuccessfully:YES];
        }
        else {
            [self.delegate userDidSignInSuccessfully:NO];
        }
        
    }];
    
    [dataTask resume];
    
}

-(void)sendSignUpRequestToParseWithUsername:(NSString *)username password:(NSString *)pass andPhone:(NSString *)number{
    
    NSString *post = [NSString stringWithFormat:@"{\"username\":%@\",\"password\":\"%@,\"phone\":\"%@\"}", username, pass, number];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.parse.com/1/users/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSDictionary *headers = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
                              @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo",
                              @"X-Parse-Revocable-Session":@"1", @"Content-Type":@"application/json"};
    
    [configuration setHTTPAdditionalHeaders:headers];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSString *string = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", request);
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
                if ([httpResponse statusCode] == 200) {
                    //User *current = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    //self.loggedUser = current;
        
                    [self.delegate userDidSignInSuccessfully:YES];
                }
                else {
                    [self.delegate userDidSignInSuccessfully:NO];
                }

    }];
    
    [dataTask resume];
}

@end
