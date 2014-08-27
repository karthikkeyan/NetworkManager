//
//  NSData+NetworkManager.h
//  LZoom
//
//  Created by கார்த்திக் கேயன் on 13/06/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Error;

@interface NSData (NetworkManager)

- (BOOL) isSuccess:(Error **)error responseData:(id *)responseData error:(NSError *)error response:(NSURLResponse *)response;

@end
