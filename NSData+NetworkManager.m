//
//  NSData+NetworkManager.m
//  LZoom
//
//  Created by கார்த்திக் கேயன் on 13/06/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "Error.h"
#import "Defines.h"
#import "NSData+NetworkManager.h"

@implementation NSData (NetworkManager)

- (BOOL) isSuccess:(Error **)err responseData:(id *)responseData error:(NSError *)error response:(NSURLResponse *)response {
    NSUInteger code = [(NSHTTPURLResponse *)response statusCode];
    
    BOOL isSuccess = YES;
    if (error) {
        [Defines log:error key:@"Error"];
        
        *err = [Error errorWithError:error];
        isSuccess = NO;
    }
    else {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
        [Defines log:dict key:@"Response"];
        
        if (code == 200) {
            if (dict[@"data"]) {
                *responseData = dict[@"data"];
            }
            else {
                *responseData = dict;
            }
        }
        else {
            *err = [Error new];
            [*err parse:dict];
            [*err setCode:code];
            isSuccess = NO;
        }
    }
    
    return isSuccess;
}

@end
