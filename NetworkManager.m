//
//  NetworkManager.m
//  LZoom
//
//  Created by கார்த்திக் கேயன் on 13/06/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "Error.h"
#import "Defines.h"
#import "Reachability.h"
#import "NetworkManager.h"
#import "NSData+NetworkManager.h"
#import "NSString+NetworkManager.h"

static NetworkManager *manager = nil;

@interface NetworkManager () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *apiSession;

@end


@implementation NetworkManager

#pragma mark - Class Methods

+ (id) allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        if (manager == nil) {
            manager = [super allocWithZone:zone];
            
            return manager;
        }
    }
    
    return nil;
}

+ (id) copyWithZone:(NSZone *)zone {
    return self;
}

+ (instancetype) manager {
    if (manager == nil) {
        manager = [NetworkManager new];
    }
    
    return manager;
}

+ (NSString *) backgroundIdentifier {
    return @"com.lzoom.ios.network.identifier";
}

+ (NSString *) method:(NMRequestMethod)type {
    NSString *method;
    
    switch (type) {
        case NMRequestMethodGet:
            method = @"GET";
            break;
        
        case NMRequestMethodPost:
            method = @"POST";
            break;
            
        case NMRequestMethodDelete:
            method = @"DELETE";
            break;
            
        case NMRequestMethodPut:
            method = @"PUT";
            break;
            
        default:
            method = @"GET";
            break;
    }
    
    return method;
}


#pragma mark - Public Methods

- (NSURLSession *) apiSession {
    if (!_apiSession) {
        NSUInteger size = 1024 * 1024 * 100;            // 100 MB
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:size diskCapacity:size diskPath:nil];
        [NSURLCache setSharedURLCache:cache];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        configuration.timeoutIntervalForRequest = 60;
        configuration.timeoutIntervalForResource = 60;
        configuration.URLCache = cache;
        
        _apiSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    return _apiSession;
}

- (NSUInteger) request:(NSString *)path
                method:(NMRequestMethod)method
                params:(NSDictionary *)params
            completion:(NMCompetionHandler)completion {
    NSString *url = [Defines.APIBaseURL stringByAppendingString:path];
    [Defines log:url key:@"API URL"];
    
    NSMutableURLRequest *request = [self requestWithURL:url params:params method:method];
    
    if (_token) {
        [request setValue:_token forHTTPHeaderField:@"token"];
        [Defines log:_token key:@"Token"];
    }
    
    [Defines log:params key:@"Params Dictionary"];
    
    typeof(self) __weak weakSelf = self;
    NSURLSessionDataTask *task = [self.apiSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        Error *err;
        id responseData;
        
        if ([data isSuccess:&err responseData:&responseData error:error response:response]) {
            if (completion) { completion(responseData, nil); }
        }
        else {
            if (completion) { completion (nil, err); }
        }
        
        [weakSelf updateNetworkIndicator];
    }];
    [task resume];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    return task.taskIdentifier;
}

- (NSUInteger) anonymousRequest:(NSString *)path
                         method:(NMRequestMethod)method
                         params:(NSDictionary *)params
                     completion:(NMCompetionHandler)completion {
    NSMutableURLRequest *request = [self requestWithURL:path params:params method:method];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion) {
            if (error) {
                completion (nil, [Error errorWithError:error]);
            }
            else {
                id responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                completion (responseDict, nil);
            }
        }
    }];
    [task resume];
    
    return task.taskIdentifier;
}


#pragma mark - Private Methods

- (NSMutableURLRequest *) requestWithURL:(NSString *)url params:(NSDictionary *)params method:(NMRequestMethod)method {
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.URL =[NSURL URLWithString:url];
    request.HTTPMethod = [NetworkManager method:method];
    
    if (params) {
        if (method == NMRequestMethodPost || method == NMRequestMethodPut) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            NSData *httpBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            request.HTTPBody = httpBody;
        }
        else {
            request.URL = [NSURL URLWithString:[url appendQueryString:params]];
        }
    }
    
    return request;
}

- (void) updateNetworkIndicator {
    [_apiSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        BOOL visible = ((dataTasks.count + uploadTasks.count + downloadTasks.count) > 0);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    }];
}

@end
