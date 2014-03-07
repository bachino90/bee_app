//
//  BeeUser.h
//  Bee
//
//  Created by Emiliano Bivachi on 06/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface BeeUser : NSObject

+ (BeeUser *)sharedUser;

+ (BOOL)isLoggedin;
+ (NSArray *)basicPermissions;

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

@end
