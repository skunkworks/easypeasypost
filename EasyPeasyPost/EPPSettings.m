//
//  EPPSettings.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPSettings.h"

@implementation EPPSettings

+ (EPPSettings *)sharedSettings
{
    static EPPSettings *settings;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[EPPSettings alloc] init];
    });
    
    return settings;
}

#define API_KEY @"EasyPostAPIKey"
- (id)init
{
    if (self = [super init]) {
        NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:API_KEY];
        _apiKey = apiKey;
    }
    return self;
}

- (void)setApiKey:(NSString *)apiKey
{
    _apiKey = apiKey;
    [[NSUserDefaults standardUserDefaults] setObject: apiKey forKey:API_KEY];
}

@end
