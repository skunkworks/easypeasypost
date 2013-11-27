//
//  EPPAddress.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAddress.h"
#import "NSDictionary+URLString.h"
#import "EPPEndpoint.h"

@implementation EPPAddress

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:self.street1];
    if (self.city && self.city.length) {
        [description appendString:[NSString stringWithFormat:@", %@", self.city]];
    }
    if (self.state && self.state.length) {
        [description appendString:[NSString stringWithFormat:@", %@", self.state]];
    }
    if (self.zip && self.zip.length) {
        [description appendString:[NSString stringWithFormat:@" %@", self.zip]];
    }
    return [description copy];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *address = [NSMutableDictionary dictionary];

    if (!self.street1) {
        [NSException raise:@"Invalid address" format:@"Street 1 is required"];
    }
    address[@"street1"] = self.street1;
    if (self.street2) address[@"street2"] = self.street2;
    if (self.city) address[@"city"] = self.city;
    if (self.state) address[@"state"] = self.state;
    if (self.zip) {
        address[@"zip"] = self.zip;
    } else if (!self.city || !self.state) {
        [NSException raise:@"Invalid address" format:@"Must have both city/state if no zip code is provided"];
    }
    
    if (self.name) {
        address[@"name"] = self.name;
    } else if (!self.company) {
        [NSException raise:@"Invalid address" format:@"Must provide either name or company"];
    }
    if (self.company) address[@"company"] = self.company;
    
    // Optional(ish) address properties
    if (self.country) address[@"country"] = self.country;
    if (self.phone) address[@"phone"] = self.phone;
    if (self.email) address[@"email"] = self.email;
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:address forKey:@"address"];
    return [dict copy];
}

- (void)saveOnCompletion:(void(^)(EPPAddress *address, NSString *errorMessage))completionHandler
{
    NSString *addressParameterString = [[self dictionary] urlEncodedString];
    EPPEndpoint *endpoint = [[EPPEndpoint alloc] init];
    
    [endpoint performPostRequestOnResourceURL:@"/addresses"
                               withParameters:addressParameterString
                                 onCompletion:^(NSHTTPURLResponse *response, NSError *error)
     {
         if (error) {
             completionHandler(NO, [NSString stringWithFormat:@"%@", error]);
         } else {
             if (response.statusCode == 200) {
                 // TODO: parse JSON response, save to self
                 // Don't forget about saving the very important
                 // id, createdAt, and updatedAt readonly fields
                 completionHandler(self, nil);
             } else {
                 completionHandler(nil, @"Failed to save address. Is your API key valid?");
             }
         }
     }];
}

@end
