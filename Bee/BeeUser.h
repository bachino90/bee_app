//
//  BeeUser.h
//  Bee
//
//  Created by Emiliano Bivachi on 06/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class BeeUser;
@protocol BeeUserDelegate <NSObject>
- (void)userSignOut;
@end

@interface BeeUser : NSObject

@property (nonatomic, weak) id <BeeUserDelegate> delegate;
@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *sessionToken;

+ (BeeUser *)sharedUser;

- (BOOL)isLoggedin;
- (BOOL)isLoggedinFacebook;
- (BOOL)isLoggedinTwitter;
- (void)setNewSession:(NSDictionary *)response;
- (void)userSignOut;


+ (NSArray *)basicPermissions;
- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

@end
