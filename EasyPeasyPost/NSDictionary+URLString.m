//
//  NSDictionary+URLString.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "NSDictionary+URLString.h"

@implementation NSDictionary (URLString)

- (NSString *)urlEscapedString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL, kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

- (NSString *)urlEncodedString
{
    NSMutableArray *pairs = [NSMutableArray array];
    
    for (NSString *key in self.allKeys) {
        id value = self[key];
        
        if ([value isKindOfClass:[NSString class]]) {
            NSString *escapedValue = [self urlEscapedString:value];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subvalue in value) {
                NSString *escapedSubvalue = [self urlEscapedString:subvalue];
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escapedSubvalue]];
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subkey in value) {
                NSString *escapedSubvalue = [self urlEscapedString:value[subkey]];
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subkey, escapedSubvalue]];
            }
        } else {
            NSLog(@"Naughty incompatible object found in dictionary");
        }
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

@end
