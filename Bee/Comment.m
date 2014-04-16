//
//  Comment.m
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)comment {
    self = [super init];
    if (self) {
        NSDictionary *secret_id = comment[@"id"];
        self.commentID = secret_id[[[secret_id allKeys] firstObject]];
        self.avatarID = @"";//secret[@"avatar_id"];
        self.content = comment[@"content"];
        self.likesCount = 0;//[secret[@"likes_count"] integerValue];
        self.iAmAuthor = [comment[@"i_am_author"] boolValue];
        self.friendIsAuthor = [comment[@"author_is_friend"] boolValue];
        NSString *dateString = comment[@"created_at"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        self.createdAt = [dateFormat dateFromString:dateString];
    }
    return self;
}

- (instancetype)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        self.commentID = @"";
        self.avatarID = @"";//secret[@"avatar_id"];
        self.content = content;
        self.likesCount = 0;
        self.iAmAuthor = YES;
        self.friendIsAuthor = NO;
    }
    return self;
}

@end
