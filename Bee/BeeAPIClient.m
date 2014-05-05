//
//  BeeAPIClient.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeAPIClient.h"
#import "BeeUser.h"

static NSString * const kBeeAPIBaseURLString = @"http://bachino90-bee.herokuapp.com/api/v1/";//@"http://localhost:3000/api/v1/";//

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
    NSString *endPoint = [NSString stringWithFormat:@"users"];
    [self.requestSerializer clearAuthorizationHeader];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:signup, @"user",
                                                                          self.deviceID, @"device_id", nil];
    [self POST:endPoint parameters:parameters success:success failure:failure];
}

- (void)signinUserWithData:(NSDictionary *)sessionParams
                  success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                  failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"sessions"];
    [self.requestSerializer clearAuthorizationHeader];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:sessionParams, @"session",
                                                                          self.deviceID, @"device_id", nil];
    [self POST:endPoint parameters:parameters success:success failure:failure];
}

- (void)signoutUserWithData:(NSDictionary *)session
                    success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                    failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"signout"];
    [self DELETE:endPoint parameters:nil success:success failure:failure];
}

- (void)signinWithFacebookData:(NSDictionary *)facebookData
                       success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                       failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    
}

- (void)updateFriendsList:(NSArray *)friendList
                  success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                  failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    //NSString *endPoint = [NSString stringWithFormat:@"users/%@/facebook/friends", self.userID];
    //NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:friendList, @"friends_list", nil];
    //[self PUT:endPoint parameters:parameters success:success failure:failure];
}

- (void)GETUserInfoSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@", self.userID];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

#pragma mark - NOTIFICATIONS

- (void)PUTPushNotificationToken:(NSString *)token
                         Success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                         failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/pushToken",self.userID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token",
                                self.deviceID, @"device_id", nil];
    [self PUT:endPoint parameters:parameters success:success failure:failure];
}

- (void)GETRecentNotificationsSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSDictionary *paramenters = nil;
    if (self.notificationRecentUpdate) {
        paramenters = [NSDictionary dictionaryWithObjectsAndKeys:[self.notificationRecentUpdate description], @"notification_recent_update", nil];
    }
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/notifications",self.userID];
    [self GET:endPoint parameters:paramenters success:success failure:failure];
}

- (void)GETOldNotificationsSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                           failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSDictionary *paramenters = nil;
    if (self.notificationLastUpdate) {
        paramenters = [NSDictionary dictionaryWithObjectsAndKeys:[self.notificationLastUpdate description], @"notification_last_update", nil];
    }
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/notifications/last",self.userID];
    [self GET:endPoint parameters:paramenters success:success failure:failure];
}

#pragma mark - SECRETS

- (void)GETRecentSecretsAbout:(NSString *)about
                      friends:(BOOL)friendsSecrets
                      success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                      failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSLog(@"%@",self.requestSerializer.HTTPRequestHeaders);
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets", self.userID];
    NSDictionary *parameters = nil;
    if (self.secretRecentUpdate) {
        NSString *recentDateStr = [self.secretRecentUpdate description];
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:recentDateStr, @"recent_update_at", nil];
    }
    [self GET:endPoint parameters:parameters success:success failure:failure];
}

- (void)GETPastSecretsAbout:(NSString *)about
                    friends:(BOOL)friendsSecrets
                    success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                    failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSLog(@"%@",self.requestSerializer.HTTPRequestHeaders);
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/last", self.userID];
    NSString *pastDateStr = [self.secretLastUpdate description];
    NSDictionary *paramenters = [NSDictionary dictionaryWithObjectsAndKeys:pastDateStr, @"last_update_at", nil];
    [self GET:endPoint parameters:paramenters success:success failure:failure];
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
    [self DELETE:endPoint parameters:nil success:success failure:failure];
}

#pragma mark - COMMENTS

- (void)GETCommentsForSecret:(NSString *)secretID
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/comments", self.userID, secretID];
    [self GET:endPoint parameters:nil success:success failure:failure];
}

- (void)POSTComment:(NSDictionary *)commentParameters
           inSecret:(NSString *)secretID
            success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
            failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/comments", self.userID, secretID];
    [self POST:endPoint parameters:commentParameters success:success failure:failure];
}

- (void)DELETEComment:(NSString *)commentID
             inSecret:(NSString *)secretID
              success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSString *endPoint = [NSString stringWithFormat:@"users/%@/secrets/%@/comments/%@", self.userID, secretID, commentID];
    [self DELETE:endPoint parameters:nil success:success failure:failure];
}


@end
