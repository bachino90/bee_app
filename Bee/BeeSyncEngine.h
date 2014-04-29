//
//  BeeSyncEngine.h
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeeSyncEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (BeeSyncEngine *)sharedEngine;

- (void)startRecentSync;
- (void)startOldSync;

- (void)startSearchingRecentCommentsForSecret:(Secret *)secret;
- (void)startSearchingOldCommentsForSecret:(Secret *)secret;

- (void)startPostingComment:(NSDictionary *)comment forSecret:(Secret *)secret;
- (void)startRePostingComment:(Comment *)comment forSecret:(Secret *)secret;
- (void)startDeletingComment:(Comment *)comment forSecret:(Secret *)secret;

- (void)startSearchingRecentNotifications;
- (void)startSearchingOldNotifications;

@end
