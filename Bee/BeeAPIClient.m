//
//  BeeAPIClient.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeAPIClient.h"

static NSString * const kBeeAPIBaseURLString = @"http://localhost:3000/api/v1/";

static NSString * const kBeeAPIKey = @"API_KEY";

@implementation BeeAPIClient

+ (BeeAPIClient *)sharedClient {
    static dispatch_once_t once;
    static BeeAPIClient *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBeeAPIBaseURLString]];
        sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        sharedInstance.requestSerializer = [AFHTTPRequestSerializer serializer];
        //[sharedInstance.requestSerializer setAuthorizationHeaderFieldWithToken:@""];
        //[sharedInstance.requestSerializer setAuthorizationHeaderFieldWithUsername:@"" password:@""];
    });
    return sharedInstance;
}

- (void)GETUserInfoSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/530b7e4f4d616319af000000"];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

- (void)GETSecretsAbout:(NSString *)about
                friends:(BOOL)friendsSecrets
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
    NSString *endPoint = [NSString stringWithFormat:@"users/530b7e4f4d616319af000000/secrets"];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

- (void)POSTSecret:(NSDictionary *)secretParameters
           success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
           failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/530b7e4f4d616319af000000/secrets"];
    [self POST:endPoint parameters:secretParameters success:success failure:failure];
}

- (void)PUTLikeOnSecret:(NSString *)secretID
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)DELETELikeOnSecret:(NSString *)secretID
                   success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)DELETESecret:(NSString *)secretID
             success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
             failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)GETCommentsForSecret:(NSString *)secretID
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)POSTComment:(NSDictionary *)commentParameters
          forSecret:(NSString *)secretID
            success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
            failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)DELETEComment:(NSString *)commentID
              success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}


@end
