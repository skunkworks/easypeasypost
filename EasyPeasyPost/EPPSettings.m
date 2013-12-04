//
//  EPPSettings.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPSettings.h"

@implementation EPPSettings

#define API_KEY @"EasyPostAPIKey"

@synthesize apiKey = _apiKey;

- (NSString *)apiKey
{
    if (!_apiKey) {
        _apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:API_KEY];
    }
    return _apiKey;
}

- (void)setApiKey:(NSString *)apiKey
{
    _apiKey = apiKey;
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:API_KEY];
}

@end
