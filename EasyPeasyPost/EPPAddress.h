//
//  EPPAddress.h
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPPAddress : NSObject

// Unique, begins with 'adr_'
@property (nonatomic, readonly) NSString *id;
// Required
@property (nonatomic, strong) NSString *street1;
// Optional
@property (nonatomic, strong) NSString *street2;
// Required if ZIP is not present
@property (nonatomic, strong) NSString *city;
// Required if ZIP is not present
@property (nonatomic, strong) NSString *state;
// Required if city & state are not present
@property (nonatomic, strong) NSString *zip;
// 2 character code, defaults to US
@property (nonatomic, strong) NSString *country;
// Either name or company is required for addresses
@property (nonatomic, strong) NSString *name;
// Either company or name is required for addresses
@property (nonatomic, strong) NSString *company;
// Required for some carrier services in "from" addresses
@property (nonatomic, strong) NSString *phone;
// Optional
@property (nonatomic, strong) NSString *email;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

// Returns NSDictionary representation of address
- (NSDictionary *)dictionary;

- (void)saveOnCompletion:(void(^)(EPPAddress *address, NSString *errorMessage))completionHandler;

@end
