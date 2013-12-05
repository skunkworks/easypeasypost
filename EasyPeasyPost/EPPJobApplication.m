//
//  EPPJobApplication.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 12/4/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPJobApplication.h"
#import "EPPEndpoint.h"
#import "NSDictionary+URLString.h"


@implementation EPPJobApplication

- (id)initWithJobTitle:(NSString *)jobTitle build:(NSString *)build
{
    if (self = [super init]) {
        _jobTitle = jobTitle;
        _build = build;
    }
    return self;
}

- (void)sendOnCompletion:(void(^)(NSString *errorMessage))completionHandler
{
    NSDictionary *dictionary = @{@"job_title" : self.jobTitle,
                                 @"build" : self.build};
    NSString *parameters = [dictionary urlEncodedString];
    
    // NSLog(@"URL parameter string: %@", parameters);
    
    EPPEndpoint *endpoint = [[EPPEndpoint alloc] init];
    [endpoint performPostRequestOnResourceURL:@"/apply"
                               withParameters:parameters
                                 onCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error)
     {
         if (error) {
             NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", error];
             completionHandler(errorMessage);
         } else {
             if (response.statusCode == 200 ||
                 response.statusCode == 201 ||
                 response.statusCode == 202) {
                 
                 completionHandler(nil);
                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:nil];
                 NSLog(@"Response from job application: %@", dictionary);
             } else {
                 NSString *errorMessage = @"Error: failed to send job application. Is your API key valid?";
                 completionHandler(errorMessage);
                 NSLog(@"%@", errorMessage);
             }
         }
     }];
}

@end
