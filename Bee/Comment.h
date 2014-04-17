//
//  Comment.h
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CommentSuccessDelivered = 0,
    CommentFailDelivered,
    CommentDelivered,
} CommentState;

@interface Comment : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)secret;
- (instancetype)initWithContent:(NSString *)content;

@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *avatarID;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic) NSInteger likesCount;
@property (nonatomic) BOOL iAmAuthor;
@property (nonatomic) BOOL friendIsAuthor;
@property (nonatomic) CommentState state;
@property (nonatomic, readonly) NSString *dateString;

@end
