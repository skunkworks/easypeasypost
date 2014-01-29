//
//  EPPCommunicator.h
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//
//
//  Can only handle one communication request at a time. Create another instance to send another request.

#import <Foundation/Foundation.h>

@interface EPPCommunicator : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

- (void)performGetRequestOnResourceURL:(NSString *)resourceURL
                          onCompletion:(void(^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionHandler;

- (void)performPostRequestOnResourceURL:(NSString *)resourceURL
                         withParameters:(NSString *)parameterString
                           onCompletion:(void(^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionHandler;
@end
