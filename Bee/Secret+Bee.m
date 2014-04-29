//
//  Secret+Bee.m
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Secret+Bee.h"

@implementation Secret (Bee)

+ (NSArray *)colors {
    static NSArray *colors;
    if (colors) {
        return colors;
    }
    colors = @[[UIColor turquoiseColor], [UIColor emerlandColor], [UIColor peterRiverColor], [UIColor amethystColor], [UIColor wetAsphaltColor], [UIColor carrotColor], [UIColor sunflowerColor], [UIColor alizarinColor], [UIColor concreteColor]];
    return colors;
}

+ (NSArray *)fonts {
    static NSArray *fonts;
    if (fonts) {
        return fonts;
    }
    fonts = [UIFont secretsFonts];
    return fonts;
}

- (UIColor *)color {
    NSArray *ar = [self.about componentsSeparatedByString:@","];
    if (ar.count == 2) {
        return [Secret colors][[ar[0] intValue]];
    } else {
        return [Secret colors][0];
    }
}

- (UIFont *)font {
    NSArray *ar = [self.about componentsSeparatedByString:@","];
    if (ar.count == 2) {
        return [Secret fonts][[ar[1] intValue]];
    } else {
        return [Secret fonts][0];
    }
}

/*
static NSString *const kItemsKey = @"Comment";

-(void)addCommentsObject:(Comment *)value
{
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}
*/
/*
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
        //NSArray *ar = [self.about componentsSeparatedByString:@","];
        // if (ar.count == 2) {
        // self.color = [Secret colors][[ar[0] intValue]];
        // self.font = [Secret fonts][[ar[1] intValue]];
        // }
        self.commentsCount = [secret[@"comments_count"] integerValue];
        self.likesCount = [secret[@"likes_count"] integerValue];
        self.author = [secret[@"author"] integerValue];
        self.iLikeIt = [secret[@"i_like_it"] boolValue];
        NSString *dateString = secret[@"created_at"];
        self.createdAt = [[self dateFormatter] dateFromString:dateString];
    }
    return self;
}
*/
@end
