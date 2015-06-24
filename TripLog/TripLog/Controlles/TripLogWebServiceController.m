//
//  TripLogWebServiceController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripLogWebServiceController.h"
#import "Trip+DictionaryInitializator.h"

@interface TripLogWebServiceController () <NSURLSessionDelegate>

@end

@implementation TripLogWebServiceController{
    NSDictionary *mainHeaders;
}

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
            mainHeaders = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
                            @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo"};
        }
    }
    
    return webController;
}

#pragma mark Sign In/Sign Up to Parse

-(void)sendSignInRequestToParseWithUsername:(NSString*)username andPassword:(NSString*)password{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:mainHeaders];
    [headers setObject:@"1" forKey:@"X-Parse-Revocable-Session"];
    [configuration setHTTPAdditionalHeaders:headers];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.parse.com/1/login?username=%@&password=%@", username, password]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *current = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString* userId = [current objectForKey:@"objectId"];
            NSString* sessionToken = [current objectForKey:@"sessionToken"];
            
            [[TripLogController sharedInstance] setLoggedUserId:userId];
            [[TripLogController sharedInstance] setLoggedUserName:[current objectForKey:@"username"]];
            
            [self.delegate userDidSignInSuccessfully:YES withUserId:userId andSessionToken:sessionToken];
        }
        else {
            [self.delegate userDidSignInSuccessfully:NO withUserId:nil andSessionToken:nil];
        }
        
    }];
    
    [dataTask resume];
}

-(void)sendSignUpRequestToParseWithUsername:(NSString *)username password:(NSString *)pass andPhone:(NSString *)number{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.parse.com/1/users/"]];
    [request setHTTPMethod:@"POST"];
    
    // Set HTTP headers
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"1" forHTTPHeaderField:@"X-Parse-Revocable-Session"];
    
    NSDictionary *dict = @{@"username":username, @"password":pass, @"phone":number};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         if (!data) {
             [self.signUpDelegate userDidSignUpSuccessfully:NO];
             return;
         }
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
         NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
         
         if ([httpResponse statusCode] == 201) {
             NSLog(@"Registration successful!");
             [self.signUpDelegate userDidSignUpSuccessfully:YES];
         }
         else{
             NSLog(@"Registration failed!");
             [self.signUpDelegate userDidSignUpSuccessfully:NO];
         }
     }];
}

#pragma mark Fetch/Send objects to Parse

-(void)sendPostRequestForTripToParseWithName:(NSString*)name country:(NSString*)country city:(NSString*)city description:(NSString*)description raiting:(int)raiting isPrivate:(BOOL)isPrivate latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude userId:(NSString*)userId withCompletitionHandler: (void (^)(NSDictionary* response)) completition{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Trip"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setHTTPMethod:@"POST"];
    
    
    NSDictionary *dict = @{@"Name":name, @"Country":country, @"City":city, @"Description":description, @"Raiting":[NSNumber numberWithInt:raiting], @"IsPrivate":[NSNumber numberWithBool:isPrivate], @"Location": @{@"__type": @"GeoPoint", @"latitude": latitude, @"longitude": longitude }, @"User":@{ @"__type": @"Pointer",@"className": @"_User",@"objectId": userId}};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
                if ([httpResponse statusCode] == 201) {
                    NSLog(@"Trip added successfully!");
                    completition([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error]);
                }
                else{
                    NSLog(@"Trip adding failed! Error: %@", error);
                }
    }];

    [uploadTask resume];
}

-(void)sendGetRequestForAllTripsWithCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Trip"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completition(result);
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendGetRequestForTripsWithCompletionHandler:(void (^)(NSDictionary* result)) completion{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    TripLogController* tripController = [TripLogController sharedInstance];
    NSString* urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/Trip?where={\"$or\":[{\"IsPrivate\":false},{\"User\": {\"__type\": \"Pointer\",\"className\": \"_User\",\"objectId\": \"%@\"}}]}", tripController.loggedUser.userId];
    NSString* encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:encodedUrlString]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray* trips = [result objectForKey:@"results"];
            for (NSMutableDictionary* tripProperties in trips) {
                [tripProperties setObject:@(YES) forKey:IS_SYNCHRONIZED_KEY];
                
                NSString* tripId = [tripProperties objectForKey:ID_KEY];
                [self sendSyncGetRequestForSingleImageWithTripIdAndHighestRating:tripId andCompletitionHandler:^(NSDictionary *result) {
                    NSArray* images = [result objectForKey:@"results"];
                    if([images count] > 0){
                        NSDictionary* entryInfo = [images firstObject];
                        NSDictionary* imageInfo = [entryInfo objectForKey:@"Image"];
                        [tripProperties setValue:[imageInfo objectForKey:@"url"] forKey:IMAGE_URL_KEY];
                    }
                }];
            }
            
            completion(result);
        }
        else{
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendGetRequestForTripCommentWithTripId: (NSString*)tripId andCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/TripComment?where={\"Trip\": {\"__type\": \"Pointer\",\"className\": \"Trip\",\"objectId\": \"%@\"}}", tripId];
    NSString* urlString2 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completition(result);
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendGetRequestForImagesWithTripId: (NSString*)tripId andCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/Images?where={\"Trip\": {\"__type\": \"Pointer\",\"className\": \"Trip\",\"objectId\": \"%@\"}, \"IsPublic\":true}", tripId];
    NSString* urlString2 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completition(result);
            NSMutableArray *results = [result objectForKey:@"results"];
            
            if([results count] > 0){
                self.imageURL = [[results[0] objectForKey:@"Image"] objectForKey:@"url"];
                NSLog(@"%@", [[results[0] objectForKey:@"Image"] objectForKey:@"url"]);
                NSLog(@"ImageURL:%@",self.imageURL);
            }else{
                NSLog(@"Fetch unsuccessfull!");
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendGetRequestForImagesWithTripId: (NSString*)tripId userId:(NSString*)userId andCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/Images?where={\"Trip\": {\"__type\": \"Pointer\",\"className\": \"Trip\",\"objectId\": \"%@\"},\"User\": {\"__type\": \"Pointer\",\"className\": \"_User\",\"objectId\": \"%@\"}}", tripId, userId];
    NSString* urlString2 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completition(result);
            NSMutableArray *results = [result objectForKey:@"results"];
            
            if([results count] > 0){
                self.imageURL = [[results[0] objectForKey:@"Image"] objectForKey:@"url"];
                NSLog(@"%@", [[results[0] objectForKey:@"Image"] objectForKey:@"url"]);
                NSLog(@"ImageURL:%@",self.imageURL);
            }else{
                NSLog(@"Fetch unsuccessfull!");
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendGetRequestForUserWithId: (NSString*)userId andCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/_User?where={\"objectId\": \"%@\"}", userId];
    NSString* urlString2 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completition(result);
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendGetRequestForSingleImageWithTripIdAndHighestRating: (NSString*)tripId andCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:mainHeaders];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/Images?where={\"Trip\": {\"__type\": \"Pointer\",\"className\": \"Trip\",\"objectId\": \"%@\"}}&order=-raiting&limit=1", tripId];
    NSString* urlString2 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completition(result);
            }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [dataTask resume];
}

-(void)sendSyncGetRequestForSingleImageWithTripIdAndHighestRating: (NSString*)tripId andCompletitionHandler: (void (^)(NSDictionary *result)) completition{
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/Images?where={\"Trip\": {\"__type\": \"Pointer\",\"className\": \"Trip\",\"objectId\": \"%@\"}}&order=-raiting&limit=1", tripId];
    NSString* urlStringEncoded = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    for (NSString* key in mainHeaders.allKeys) {
        [request addValue:[mainHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    
    NSURLResponse* response;
    NSError* error = nil;
    
    //Capturing server response
    NSData* data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
    if ([httpResponse statusCode] == 200) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        completition(result);
    }
    else {
        NSLog(@"%@", error);
    }
}

-(void)sendPutRequestForShareImageWithImageId: (NSString*)imageId andCompletitionHandler: (void (^)(NSDictionary *result,NSInteger status)) completition{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/Images/%@", imageId];
    NSString* urlStringEncoded = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    for (NSString* key in mainHeaders.allKeys) {
        [request addValue:[mainHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    NSDictionary *dict = @{@"IsPublic":@(YES)};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger status = [httpResponse statusCode];
        NSDictionary* result;
        if (status == 200) {
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        }
        else {
            NSLog(@"%@", error);
        }
        
        completition(result, status);
    }];
    
    [dataTask resume];
}

-(void)sendPostRequestForImageWithData:(NSData*)imageData usedId:(NSString*)userId tripId:(NSString*)tripId isPublic:(NSNumber*)isPublic andCompletitionHandler: (void (^)(NSDictionary *result, NSInteger statusCode)) completition{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/files/%@and%@", userId,tripId];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    for (NSString* key in mainHeaders.allKeys) {
        [request addValue:[mainHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithRequest:request fromData:imageData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] == 201) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSString* name = [result objectForKey:@"name"];
            
            NSString *urlStringImages = @"https://api.parse.com/1/classes/Images";
            [request setURL:[NSURL URLWithString:urlStringImages]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            NSDictionary *dict = @{@"Image":@{@"name":name, @"__type":@"File"}, @"User":@{ @"__type": @"Pointer", @"className": @"_User",@"objectId": userId}, @"Trip":@{ @"__type": @"Pointer", @"className": @"Trip", @"objectId": tripId}, @"IsPublic":isPublic};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:jsonData];
            
            NSURLResponse* response;
            NSError* error = nil;
            
            //Capturing server response
            NSData* data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSInteger status = [httpResponse statusCode];
            NSDictionary *secondaryResult;
            if (status == 201) {
                secondaryResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            }
            else {
                NSLog(@"%@", error);
            }
            
            completition(secondaryResult, status);
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    [uploadTask resume];
}


@end
