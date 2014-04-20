//
//  Comment+Bee.h
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Comment.h"

@interface Comment (Bee)

+ (Comment *)newCommentWithDictionary:(NSDictionary *)comment;
+ (Comment *)newCommentWithContent:(NSString *)content;

- (NSString *)dateString;

@end
