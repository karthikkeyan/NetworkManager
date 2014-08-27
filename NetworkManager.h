//
//  NetworkManager.h
//  LZoom
//
//  Created by கார்த்திக் கேயன் on 13/06/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Error;

typedef void (^NMCompetionHandler)(id response, Error *error);

typedef enum {
    NMRequestMethodGet = 0,
    NMRequestMethodPost,
    NMRequestMethodDelete,
    NMRequestMethodPut
}NMRequestMethod;

@interface NetworkManager : NSObject

@property (nonatomic, copy) NSString *token;

#pragma mark - Class Methods
+ (instancetype) manager;

+ (NSString *) backgroundIdentifier;

#pragma mark - Public Methods
- (NSURLSession *) apiSession;

- (NSUInteger) request:(NSString *)path
                method:(NMRequestMethod)method
                params:(NSDictionary *)params
            completion:(NMCompetionHandler)completion;

- (NSUInteger) anonymousRequest:(NSString *)path
                         method:(NMRequestMethod)method
                         params:(NSDictionary *)params
                     completion:(NMCompetionHandler)completion;

@end
