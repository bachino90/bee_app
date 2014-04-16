//
//  Notification.h
//  Bee
//
//  Created by Emiliano Bivachi on 18/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)secret;

@property (nonatomic, strong) NSString *secretID;
@property (nonatomic) BOOL isLike;
@property (nonatomic) BOOL isComment;
@property (nonatomic, strong) NSDate *createdAt;

@end
