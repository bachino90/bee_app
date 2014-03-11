//
//  BeeAPIClient.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeAPIClient.h"
#import "BeeUser.h"

static NSString * const kBeeAPIBaseURLString = @"http://localhost:3000/api/v1/";

static NSString * const kBeeAPIKey = @"API_KEY";

@interface BeeAPIClient ()
@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, strong) NSString *deviceID;
@end

@implementation BeeAPIClient

+ (BeeAPIClient *)sharedClient {
    static dispatch_once_t once;
    static BeeAPIClient *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBeeAPIBaseURLString]];
        sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        sharedInstance.requestSerializer = [AFHTTPRequestSerializer serializer];
        //[sharedInstance.requestSerializer setAuthorizationHeaderFieldWithUsername:@"" password:@""];
    });
    return sharedInstance;
}

- (NSString *)deviceID {
    if (_deviceID) {
        return _deviceID;
    }
    _deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return _deviceID;
}

- (NSString *)userID {
    return [BeeUser sharedUser].userID;
}

- (void)signupUserWithData:(NSDictionary *)signup
                   success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)loginUserWithData:(NSDictionary *)sessionParams
                  success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                  failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"sessions"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:sessionParams, @"session",
                                                                       self.deviceID, @"device_id", nil];
    [self POST:endPoint parameters:parameters success:success failure:failure];
}


- (void)GETUserInfoSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@",self.userID];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

#pragma mark - SECRETS

- (void)GETSecretsAbout:(NSString *)about
                   page:(NSUInteger)page
                friends:(BOOL)friendsSecrets
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSLog(@"%@",self.requestSerializer.HTTPRequestHeaders);
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets?page=%i", self.userID, page];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

- (void)POSTSecret:(NSDictionary *)secretParameters
           success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
           failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets",self.userID];
    [self POST:endPoint parameters:secretParameters success:success failure:failure];
}

- (void)PUTLikeOnSecret:(NSString *)secretID
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/like", self.userID, secretID];
    [self PUT:endPoint parameters:nil success:success failure:failure];
}

- (void)DELETELikeOnSecret:(NSString *)secretID
                   success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/like", self.userID, secretID];
    [self DELETE:endPoint parameters:nil success:success failure:failure];
}

- (void)DELETESecret:(NSString *)secretID
             success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
             failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@", self.userID, secretID];
    [self PUT:endPoint parameters:nil success:success failure:failure];
}

#pragma mark - COMMENTS

- (void)GETCommentsForSecret:(NSString *)secretID
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/comments", self.userID, secretID];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

- (void)POSTComment:(NSDictionary *)commentParameters
          forSecret:(NSString *)secretID
            success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
            failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/comments", self.userID, secretID];
    [self POST:endPoint parameters:commentParameters success:success failure:failure];
}

- (void)DELETEComment:(NSString *)commentID
              success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}


@end
