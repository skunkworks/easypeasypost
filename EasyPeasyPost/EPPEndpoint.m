//
//  EPPEndpoint.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPEndpoint.h"
#import "EPPSettings.h"
#import "NSDictionary+URLString.h"

@interface EPPEndpoint () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURL *endpointURL;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) EPPSettings *settings;
@property (nonatomic, copy) void(^completionHandler)(NSData *data, NSHTTPURLResponse *response, NSError *error);

@end

#define ENDPOINT_BASE_URL @"https://api.easypost.com/v2"
#define ENDPOINT_SHIPMENT_URL @"/shipments"

@implementation EPPEndpoint

- (id)init
{
    if (self = [super init]) {
        _endpointURL = [NSURL URLWithString:ENDPOINT_BASE_URL];
        _settings = [[EPPSettings alloc] init];
        _apiKey = [_settings apiKey];
    }
    return self;
}

- (void)performGetRequestOnResourceURL:(NSString *)resourceURL
                          onCompletion:(void(^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionHandler
{
    self.completionHandler = completionHandler;
    
    NSURL *url = [self.endpointURL URLByAppendingPathComponent:resourceURL];
    NSURLRequest *request = [self requestForURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        completionHandler(data, (NSHTTPURLResponse *)response, error);
    }];
    
    [dataTask resume];
}

- (void)performPostRequestOnResourceURL:(NSString *)resourceURL
                         withParameters:(NSString *)parameterString
                           onCompletion:(void(^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionHandler
{
    self.completionHandler = completionHandler;
    
    NSURL *url = [self.endpointURL URLByAppendingPathComponent:resourceURL];
    NSURLRequest *request = [self postRequestForURL:url withData:parameterString];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        completionHandler(data, (NSHTTPURLResponse *)response, error);
    }];
    
    [dataTask resume];
}

- (NSURLRequest *)requestForURL:(NSURL *)url
{
    return [[self mutableURLRequestForURL:url] copy];
}

- (NSURLRequest *)postRequestForURL:(NSURL *)url withData:(NSString *)bodyData
{
    NSMutableURLRequest *request = [self mutableURLRequestForURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String]
                                        length:strlen([bodyData UTF8String])]];
    return [request copy];
}

- (NSMutableURLRequest *)mutableURLRequestForURL:(NSURL *)url
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // HTTP request header requires add'l authentication data (API key string)
    NSString *authStr = [NSString stringWithFormat:@"%@:", self.apiKey];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    [urlRequest addValue:authValue forHTTPHeaderField:@"Authorization"];

    return urlRequest;
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSLog(@"Received redirect");
    // Refuse the redirect, which will return the body of the redirect response
    completionHandler(NULL);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    // We only call the completion handler callback in cases of redirects and client-side errors.
    // The actual data response return is handled by the NSURLSessionDataTask's completion handler.
    if (error) {
        self.completionHandler(nil, (NSHTTPURLResponse *)task.response, error);
    }
}

@end
