//
//  BeeAPIClient.h
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeeAPIClient : AFHTTPSessionManager

+ (BeeAPIClient *)sharedClient;

- (void)signupUserWithData:(NSDictionary *)session
                   success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)signinUserWithData:(NSDictionary *)session
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)signOutUserWithData:(NSDictionary *)session
                    success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                    failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)POSTUserWithFacebookData:(NSDictionary *)facebookData
                         success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                         failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)GETUserInfoSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)GETSecretsAbout:(NSString *)about
                   page:(NSUInteger)page
                friends:(BOOL)friendsSecrets
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)POSTSecret:(NSDictionary *)secretParameters
           success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
           failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)PUTLikeOnSecret:(NSString *)secretID
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)DELETELikeOnSecret:(NSString *)secretID
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)DELETESecret:(NSString *)secretID
             success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
             failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)GETCommentsForSecret:(NSString *)secretID
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)POSTComment:(NSDictionary *)commentParameters
          forSecret:(NSString *)secretID
            success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
            failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)DELETEComment:(NSString *)commentID
              success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;


@end
