//
//  NSString+NetworkManager.h
//  LZoom
//
//  Created by கார்த்திக் கேயன் on 13/06/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NetworkManager)

- (NSString *) appendQueryString:(NSDictionary *)params;

@end
