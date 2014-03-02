//
//  Secret.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Secret.h"

@implementation Secret

- (instancetype)initWithDictionary:(NSDictionary *)secret {
    self = [super init];
    if (self) {
        NSDictionary *secret_id = secret[@"id"];
        self.secretID = secret_id[[[secret_id allKeys] firstObject]];
        self.content = secret[@"content"];
        self.mediaURL = secret[@"mediaURL"];
        self.comments = @[];
        self.about = secret[@"about"];
        self.commentsCount = [secret[@"comments_count"] integerValue];
        self.likesCount = [secret[@"likes_count"] integerValue];
        self.iAmAuthor = [secret[@"i_am_author"] boolValue];
        self.friendIsAuthor = [secret[@"author_is_friend"] boolValue];
        self.iLikeIt = [secret[@"i_like_it"] boolValue];
    }
    return self;
}

@end
