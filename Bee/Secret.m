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
        self.content = secret[@"content"];
        self.mediaURL = secret[@"mediaURL"];
        //self.comments = secret[@"comments"];
        self.about = secret[@"about"];
        self.commentsCount = [secret[@"comments_count"] integerValue];
        self.likesCount = [secret[@"likes_count"] integerValue];
        self.iAmAuthor = [secret[@"i_am_author"] boolValue];
        self.friendIsAuthor = [secret[@"friend_is_author"] boolValue];
    }
    return self;
}

@end
