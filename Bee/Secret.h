//
//  Secret.h
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Secret : NSObject

+ (NSArray *)colors;
+ (NSArray *)fonts;

- (instancetype)initWithDictionary:(NSDictionary *)secret;

@property (nonatomic, strong) NSString *secretID;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *mediaURL;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic) NSInteger commentsCount;
@property (nonatomic) NSInteger likesCount;
@property (nonatomic) NSInteger author;
@property (nonatomic) BOOL iLikeIt;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIFont *font;

@end
