//
//  EPPJobApplication.h
//  EasyPeasyPost
//
//  Created by Richard Shin on 12/4/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPPJobApplication : NSObject

- (id)initWithJobTitle:(NSString *)jobTitle
                 build:(NSString *)build;

- (void)sendOnCompletion:(void(^)(NSString *errorMessage))completionHandler;

@property (nonatomic, strong) NSString *jobTitle;
@property (nonatomic, strong) NSString *build;

@end
