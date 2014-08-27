//
//  NSString+NetworkManager.m
//  LZoom
//
//  Created by கார்த்திக் கேயன் on 13/06/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSString+NetworkManager.h"

@implementation NSString (NetworkManager)

- (NSString *) appendQueryString:(NSDictionary *)params {
    if (!params || params.count == 0) { return self; };
    
    NSMutableString *queryString = [NSMutableString stringWithString:self];
    
    if ([queryString rangeOfString:@"?"].location == NSNotFound) {
        [queryString appendString:@"?"];
    }
    else {
        [queryString appendString:@"&"];
    }
    
    for (NSString *key in params) {
        id value = params[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *key2 in value) {
                [queryString appendFormat:@"%@[%@]=%@&", key, key2, value[key2]];
            }
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *value2 in value) {
                [queryString appendFormat:@"%@[]=%@&", key, value2];
            }
        }
        else {
            [queryString appendFormat:@"%@=%@&", key, params[key]];
        }
    }
    
    [queryString replaceCharactersInRange:NSMakeRange(queryString.length - 1, 1) withString:@""];
    
    return queryString;
}

@end
