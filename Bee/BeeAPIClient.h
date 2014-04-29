//
//  BeeAPIClient.h
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeeAPIClient : AFHTTPSessionManager

@property (nonatomic, strong) NSDate *secretRecentUpdate;
@property (nonatomic, strong) NSDate *secretLastUpdate;
@property (nonatomic, strong) NSDate *notificationRecentUpdate;
@property (nonatomic, strong) NSDate *notificationLastUpdate;

+ (BeeAPIClient *)sharedClient;

/********* USERS *********/

// SIGN UP
- (void)signupUserWithData:(NSDictionary *)session
                   success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// SIGN IN
- (void)signinUserWithData:(NSDictionary *)session
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// SIGN OUT
- (void)signoutUserWithData:(NSDictionary *)session
                    success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                    failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// FACEBOOK SIGN IN
- (void)signinWithFacebookData:(NSDictionary *)facebookData
                       success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                       failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// FACEBOOK UPDATE FRIENDS
- (void)updateFriendsList:(NSArray *)friendList
                  success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                  failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)GETUserInfoSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                   failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

/********* NOTIFICATIONS *********/

- (void)GETRecentNotificationsSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)GETOldNotificationsSuccess:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                           failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

/********* SECRETS *********/


- (void)GETRecentSecretsAbout:(NSString *)about
                      friends:(BOOL)friendsSecrets
                      success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                      failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

- (void)GETPastSecretsAbout:(NSString *)about
                    friends:(BOOL)friendsSecrets
                    success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                    failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// POST SECRET
- (void)POSTSecret:(NSDictionary *)secretParameters
           success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
           failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// PUT LIKE
- (void)PUTLikeOnSecret:(NSString *)secretID
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// DELETE LIKE
- (void)DELETELikeOnSecret:(NSString *)secretID
                success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// DELETE SECRET
- (void)DELETESecret:(NSString *)secretID
             success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
             failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

/********* COMMENTS *********/

// GET COMMENT FROM SECRET
- (void)GETCommentsForSecret:(NSString *)secretID
                     success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                     failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// POST COMMENT
- (void)POSTComment:(NSDictionary *)commentParameters
           inSecret:(NSString *)secretID
            success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
            failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;

// DELETE COMMENT
- (void)DELETEComment:(NSString *)commentID
             inSecret:(NSString *)secretID
              success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;


@end
