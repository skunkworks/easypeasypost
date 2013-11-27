//
//  EPPAPIKeyCheck.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAPIKeyCheck.h"
#import "EPPEndpoint.h"

@implementation EPPAPIKeyCheck

+ (void)checkAPIKey:(NSString *)apiKey onCompletion:(void(^)(BOOL verified, NSString *errorMessage))completionHandler
{
    EPPEndpoint *endpoint = [[EPPEndpoint alloc] init];
    [endpoint performGetRequestOnResourceURL:@"/shipments"
                                onCompletion:^(NSHTTPURLResponse *response, NSError *error)
     {
         if (error) {
             completionHandler(NO, [NSString stringWithFormat:@"%@", error]);
         } else {
             if (response.statusCode == 200) {
                 completionHandler(YES, nil);
             } else {
                 completionHandler(NO, @"API key failed validation");
             }
         }
    }];
}

@end
