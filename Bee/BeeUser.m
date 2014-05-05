//
//  BeeUser.m
//  Bee
//
//  Created by Emiliano Bivachi on 06/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeUser.h"
#import "KeychainWrapper.h"
#import "CoreDataController.h"
#import "BeeSyncEngine.h"

#define PASSWORD_KEY (__bridge id)kSecValueData
#define USER_KEY (__bridge id)kSecAttrAccount

static NSString *kUserInfoFilename = @"UserInfo.plist";

@interface BeeUser ()
@property (nonatomic, strong) NSDictionary *facebookSession;
@property (nonatomic, strong) NSArray *facebookFriendsList;
@property (nonatomic, strong) NSDictionary *userData;

@property (nonatomic, strong) KeychainWrapper *tokenWrapper;
@property (nonatomic, readonly) NSString *userPassword;
@property (nonatomic, readonly) NSString *userEmail;
@end

@implementation BeeUser

+ (BeeUser *)sharedUser {
    static dispatch_once_t once;
    static BeeUser *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[BeeUser alloc] init];
        sharedInstance.tokenWrapper = [[KeychainWrapper alloc] init];
        if ([sharedInstance isLoggedin]) {
            [sharedInstance setAuthorizationHeader];
        }
    });
    return sharedInstance;
}

- (void)clearData {
    if ([self isLoggedin]) {
        [self.tokenWrapper resetKeychainItem];
        [[BeeSyncEngine sharedEngine]emptyAllDB];
        //[[CoreDataController sharedInstance] deleteDB];
    }
}

- (void)userSignOut {
    [[BeeAPIClient sharedClient] signoutUserWithData:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    [self facebookUserLogOut];
    [self clearData];
    [self.delegate userSignOut];
}

- (NSString *)userID {
    if (![[self.tokenWrapper myObjectForKey:USER_KEY] isEqualToString:@""]) {
        return [self.tokenWrapper myObjectForKey:USER_KEY];
    }
    else return nil;
}

- (NSString *)sessionToken {
    if (![[self.tokenWrapper myObjectForKey:PASSWORD_KEY] isEqualToString:@""]) {
        return [self.tokenWrapper myObjectForKey:PASSWORD_KEY];
    }
    else return nil;
}

- (void)setNewSession:(NSDictionary *)response {
    [self.tokenWrapper mySetObject:response[@"user_id"] forKey:USER_KEY];
    [self.tokenWrapper mySetObject:response[@"token"] forKey:PASSWORD_KEY];
    [self setAuthorizationHeader];
}

- (void)setAuthorizationHeader {
    NSString *token = [self.tokenWrapper myObjectForKey:PASSWORD_KEY];
    [[BeeAPIClient sharedClient].requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
}

- (BOOL)isLoggedin {
    if (![[self.tokenWrapper myObjectForKey:USER_KEY] isEqualToString:@""] &&
        ![[self.tokenWrapper myObjectForKey:PASSWORD_KEY] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

- (BOOL)isLoggedinFacebook {
    return NO;
}

- (BOOL)isLoggedinTwitter {
    return NO;
}

#pragma mark - Facebook things

+ (NSArray *)basicPermissions {
    return @[@"basic_info",@"email"];
}

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    if (!error && state == FBSessionStateOpen) {
        [self facebookUserLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        
        //borrar los datos de usuarios
        [self facebookUserLogOut];
    }
    
    if (error) {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        
        if ([FBErrorUtility shouldNotifyUserForError:error]) {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //show message
        } else {
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again";
                //show message
            } else {
                NSDictionary *errorInfo = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]objectForKey:@"body"]objectForKey:@"error"];
                
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInfo objectForKey:@"message"]];
                //show message
            }
        }
        
        //borrar los datos de usuarios
        [self facebookUserLogOut];
    }
}

- (void)facebookUserLogOut {
    if (FBSession.activeSession.state == FBSessionStateOpen ||
        FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)facebookUserLoggedIn {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            self.facebookSession = (NSDictionary *)result;
            if ([self isLoggedin]) {
                [self requestForMyFriends];
            } else {
                [[BeeAPIClient sharedClient] signinWithFacebookData:result success:^(NSURLSessionDataTask *task, id responseObject) {
                    self.userData = (NSDictionary *)responseObject;
                    [self requestForMyFriends];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];

            }
        }
    }];
}

- (void)requestForMyFriends {
    [[FBRequest requestForGraphPath:@"me/friends?fields=installed"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            //put friends in database
            NSLog(@"%@",result);
            self.facebookFriendsList = [(NSDictionary *)result objectForKey:@"data"];
            if (self.facebookFriendsList.count > 0) {
                NSMutableArray *friendList = [NSMutableArray array];
                for (NSDictionary *dict in self.facebookFriendsList) {
                    if ([[dict allKeys] containsObject:@"installed"]) {
                        [friendList addObject:dict[@"installed"]];
                    }
                }
                if (friendList.count > 0) {
                    [[BeeAPIClient sharedClient] updateFriendsList:friendList success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                    }];
                }
            }
        }
    }];
}



@end
