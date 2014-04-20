//
//  Secret.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Secret.h"
#import "Secret+Bee.h"

@implementation Secret


- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    if (dateFormatter) {
        return dateFormatter;
    }
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return dateFormatter;
}

- (instancetype)initWithDictionary:(NSDictionary *)secret {
    self = [super init];
    if (self) {
        NSDictionary *secret_id = secret[@"id"];
        self.secretID = secret_id[[[secret_id allKeys] firstObject]];
        self.content = secret[@"content"];
        self.mediaURL = secret[@"mediaURL"];
        self.comments = @[];
        self.about = secret[@"about"];
        /*NSArray *ar = [self.about componentsSeparatedByString:@","];
        if (ar.count == 2) {
            self.color = [Secret colors][[ar[0] intValue]];
            self.font = [Secret fonts][[ar[1] intValue]];
        }
         */
        self.commentsCount = [secret[@"comments_count"] integerValue];
        self.likesCount = [secret[@"likes_count"] integerValue];
        self.author = [secret[@"author"] integerValue];
        self.iLikeIt = [secret[@"i_like_it"] boolValue];
        NSString *dateString = secret[@"created_at"];
        self.createdAt = [[self dateFormatter] dateFromString:dateString];
    }
    return self;
}

@end
