//
//  Notification+Bee.m
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Notification+Bee.h"
#import "Secret+Bee.h"

@implementation Notification (Bee)

/*
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
*/

- (UIColor *)color {
    NSArray *ar = [self.secret_about componentsSeparatedByString:@","];
    if (ar.count == 2) {
        return [Secret colors][[ar[0] intValue]];
    } else {
        return [Secret colors][0];
    }
}

- (UIFont *)font {
    NSArray *ar = [self.secret_about componentsSeparatedByString:@","];
    if (ar.count == 2) {
        return [Secret fonts][[ar[1] intValue]];
    } else {
        return [Secret fonts][0];
    }
}

@end
