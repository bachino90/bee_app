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

@end
