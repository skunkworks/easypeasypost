//
//  EPPAPIKeyCheck.h
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPPAPIKeyCheck : NSObject

+ (void)checkAPIKey:(NSString *)apiKey onCompletion:(void(^)(BOOL verified, NSString *errorMessage))completionHandler;

@end
