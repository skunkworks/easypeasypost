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

@interface EPPEndpoint () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURL *endpointURL;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) void(^onCompletion)(NSHTTPURLResponse *response, NSError *error);

@end

#define ENDPOINT_BASE_URL @"https://api.easypost.com/v2"
#define ENDPOINT_SHIPMENT_URL @"/shipments"

@implementation EPPEndpoint

- (id)init
{
    if (self = [super init]) {
        self.endpointURL = [NSURL URLWithString:ENDPOINT_BASE_URL];
        self.apiKey = [[EPPSettings sharedSettings] apiKey];
    }
    return self;
}

- (void)performGetRequestOnResourceURL:(NSString *)resourceURL
                          onCompletion:(void(^)(NSHTTPURLResponse *response, NSError *error))completionHandler
{
    self.onCompletion = completionHandler;
    NSURL *url = [self.endpointURL URLByAppendingPathComponent:resourceURL];
    NSURLRequest *request = [self requestForURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)performPostRequestOnResourceURL:(NSString *)resourceURL
                         withParameters:(NSString *)parameterString
                           onCompletion:(void(^)(NSHTTPURLResponse *response, NSError *error))completionHandler
{
    self.onCompletion = completionHandler;
    NSURL *url = [self.endpointURL URLByAppendingPathComponent:resourceURL];
    
    NSURLRequest *request = [self postRequestForURL:url withData:parameterString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
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
    NSLog(@"Redirect response requested!");
    // Refuse the redirect, which will return the body of the redirect response
    completionHandler(NULL);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    self.onCompletion((NSHTTPURLResponse *)task.response, error);
}



@end