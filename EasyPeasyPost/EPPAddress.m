//
//  EPPAddress.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAddress.h"
#import "NSDictionary+URLString.h"
#import "EPPCommunicator.h"

@interface EPPAddress ()
@property (nonatomic, readwrite) NSString *id;
@property (nonatomic, readwrite) NSDate *createdAt;
@property (nonatomic, readwrite) NSDate *updatedAt;
@end

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
    if (self.country && self.country.length) {
        [description appendString:[NSString stringWithFormat:@" %@", self.country]];
    }
    return [description copy];
}

#define STREET1 @"street1"
#define STREET2 @"street2"
#define CITY @"city"
#define STATE @"state"
#define ZIP @"zip"
#define NAME @"name"
#define COMPANY_NAME @"company"
#define COUNTRY @"country"
#define PHONE @"phone"
#define EMAIL @"email"
#define ID @"id"
#define CREATED_AT @"created_at"
#define UPDATED_AT @"updated_at"
#define ADDRESS @"address"
#define MESSAGE @"message"

- (NSDictionary *)dictionary
{
    NSMutableDictionary *address = [NSMutableDictionary dictionary];

    if (!self.street1) {
        [NSException raise:@"Invalid address" format:@"Street 1 is required"];
    }
    address[STREET1] = self.street1;
    if (self.street2) address[STREET2] = self.street2;
    if (self.city) address[CITY] = self.city;
    if (self.state) address[STATE] = self.state;
    if (self.zip) {
        address[ZIP] = self.zip;
    } else if (!self.city || !self.state) {
        [NSException raise:@"Invalid address" format:@"Must have both city/state if no zip code is provided"];
    }
    
    if (self.name) {
        address[NAME] = self.name;
    } else if (!self.company) {
        [NSException raise:@"Invalid address" format:@"Must provide either name or company"];
    }
    if (self.company) address[COMPANY_NAME] = self.company;
    
    // Optional(ish) address properties
    if (self.country) address[COUNTRY] = self.country;
    if (self.phone) address[PHONE] = self.phone;
    if (self.email) address[EMAIL] = self.email;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:address forKey:@"address"];
    return [dict copy];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
    self.street1 = dictionary[STREET1];
    self.street2 = dictionary[STREET2] == [NSNull null] ? nil : dictionary[STREET2];
    self.city = dictionary[CITY] == [NSNull null] ? nil : dictionary[CITY];
    self.state = dictionary[STATE] == [NSNull null] ? nil : dictionary[STATE];
    self.zip = dictionary[ZIP] == [NSNull null] ? nil : dictionary[ZIP];
    self.name = dictionary[NAME] == [NSNull null] ? nil : dictionary[NAME];
    self.company = dictionary[COMPANY_NAME] == [NSNull null] ? nil : dictionary[COMPANY_NAME];
    self.country = dictionary[COUNTRY] == [NSNull null] ? nil : dictionary[COUNTRY];
    self.phone = dictionary[PHONE] == [NSNull null] ? nil : dictionary[PHONE];
    self.email = dictionary[EMAIL] == [NSNull null] ? nil : dictionary[EMAIL];
    self.id = dictionary[ID];
    self.createdAt = [self dateTimeFromRFC3339DateTimeString:dictionary[CREATED_AT]];
    self.updatedAt = [self dateTimeFromRFC3339DateTimeString:dictionary[UPDATED_AT]];
}

- (void)saveOnCompletion:(void(^)(NSString *errorMessage))completionHandler
{
    NSString *addressParameterString = [[self dictionary] urlEncodedString];
    EPPCommunicator *endpoint = [[EPPCommunicator alloc] init];
    
    [endpoint performPostRequestOnResourceURL:@"/addresses"
                               withParameters:addressParameterString
                                 onCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error)
     {
         if (error) {
             NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", error];
             completionHandler(errorMessage);
         } else {
             if (response.statusCode == 200 ||
                 response.statusCode == 201 ||
                 response.statusCode == 202) {
                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:nil];
                 [self updateFromDictionary:dictionary];

                 completionHandler(nil);
             } else {
                 NSString *errorMessage = @"Error: failed to save address. Is your API key valid?";
                 completionHandler(errorMessage);
                 NSLog(@"%@", errorMessage);
             }
         }
     }];
}

// Calls completion handler with a new address instance, leaves this instance unaltered
- (void)verifyOnCompletion:(void(^)(EPPAddress *address, NSString *errorMessage))completionHandler
{
    EPPCommunicator *endpoint = [[EPPCommunicator alloc] init];
    NSString *verifyURL = [NSString stringWithFormat:@"addresses/%@/verify", self.id];
    
    [endpoint performGetRequestOnResourceURL:verifyURL
                                onCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error)
     {
         if (error) {
             NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", error];
             completionHandler(nil, errorMessage);
         } else {
             // NSLog(@"%d response received", response.statusCode);
             if (response.statusCode == 200 ||
                 response.statusCode == 201 ||
                 response.statusCode == 202) {
                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:nil];
                 NSDictionary *addressDict = dictionary[ADDRESS];
                 EPPAddress *address = [[EPPAddress alloc] init];
                 [address updateFromDictionary:addressDict];
                 
                 if (dictionary[MESSAGE] == [NSNull null]) {
                     completionHandler(address, nil);
                 } else {
                     completionHandler(address, dictionary[MESSAGE]);
                 }
             } else if (response.statusCode == 400) {
                 NSString *errorMessage = @"Check that the address is valid.";
                 completionHandler(nil, errorMessage);
                 NSLog(@"%@", errorMessage);
             } else {
                 NSString *errorMessage = @"Check the EasyPost API key.";
                 completionHandler(nil, errorMessage);
                 NSLog(@"%@", errorMessage);
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