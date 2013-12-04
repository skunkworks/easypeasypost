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
                                 onCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error)
     {
         if (error) {
             completionHandler(NO, [NSString stringWithFormat:@"%@", error]);
         } else {
             if (response.statusCode == 200 ||
                 response.statusCode == 201 ||
                 response.statusCode == 202) {
                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:nil];
                 _id = dictionary[@"id"];
                 _createdAt = [self dateTimeFromRFC3339DateTimeString:dictionary[@"created_at"]];
                 _updatedAt = [self dateTimeFromRFC3339DateTimeString:dictionary[@"updated_at"]];

                 completionHandler(self, nil);
             } else {
                 completionHandler(nil, @"Failed to save address. Is your API key valid?");
                 NSLog(@"Error: %@", error);
             }
         }
     }];
}

- (NSDate *)dateTimeFromRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
    /*
     Returns a user-visible date time string that corresponds to the specified
     RFC 3339 date time string. Note that this does not handle all possible
     RFC 3339 date time strings, just one of the most common styles.
     */
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
    return date;
}

@end