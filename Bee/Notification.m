//
//  Notification.m
//  Bee
//
//  Created by Emiliano Bivachi on 18/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (instancetype)initWithDictionary:(NSDictionary *)notif {
    self = [super init];
    if (self) {
        self.secretID = notif[@"secret_id"];
        self.isLike = [notif[@"is_like"] boolValue];
        self.isComment = [notif[@"is_comment"] boolValue];
        NSString *dateString = notif[@"created_at"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        self.createdAt = [dateFormat dateFromString:dateString];
    }
    return self;
}

@end
