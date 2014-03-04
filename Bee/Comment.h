//
//  Comment.h
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
