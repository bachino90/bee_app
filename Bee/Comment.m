//
//  Comment.m
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)secret {
    self = [super init];
    if (self) {
        NSDictionary *secret_id = secret[@"id"];
        self.commentID = secret_id[[[secret_id allKeys] firstObject]];
        self.avatarID = @"";//secret[@"avatar_id"];
        self.content = secret[@"content"];
        self.likesCount = 0;//[secret[@"likes_count"] integerValue];
        self.iAmAuthor = [secret[@"i_am_author"] boolValue];
        self.friendIsAuthor = [secret[@"author_is_friend"] boolValue];
    }
    return self;
}

@end
