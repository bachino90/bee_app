//
//  BeeUser.m
//  Bee
//
//  Created by Emiliano Bivachi on 06/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeUser.h"

static NSString *kUserInfoFilename = @"UserInfo.plist";

@interface BeeUser ()
@property (nonatomic, strong) NSDictionary *facebookSession;
@property (nonatomic, strong) NSDictionary *userData;
@end

@implementation BeeUser

+ (BeeUser *)sharedUser {
    static dispatch_once_t once;
    static BeeUser *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[BeeUser alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)userInfoFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return [documentsDirectory stringByAppendingString:kUserInfoFilename];
}

+ (BOOL)isLoggedin {
    NSString *userInfoFilename = [BeeUser userInfoFilePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:userInfoFilename];
}

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
        [self facebookUserLoggedOut];
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
        [self facebookUserLoggedOut];
    }
}

- (void)facebookUserLoggedIn {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            self.facebookSession = (NSDictionary *)result;
            if ([BeeUser isLoggedin]) {
                [self requestForMyFriends];
            } else {
                [[BeeAPIClient sharedClient] POSTUserWithFacebookData:result success:^(NSURLSessionDataTask *task, id responseObject) {
                    self.userData = (NSDictionary *)responseObject;
                    [self requestForMyFriends];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];

            }
        }
    }];
}

- (void)facebookUserLoggedOut {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)requestForMyFriends {
    [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            //put friends in database
        }
    }];
}



@end
