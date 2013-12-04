//
//  EPPEndpoint.h
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPPEndpoint : NSObject

- (void)performGetRequestOnResourceURL:(NSString *)resourceURL
                          onCompletion:(void(^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionHandler;

- (void)performPostRequestOnResourceURL:(NSString *)resourceURL
                         withParameters:(NSString *)parameterString
                           onCompletion:(void(^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionHandler;
@end
