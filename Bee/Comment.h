//
//  Comment.h
//  Bee
//
//  Created by Emiliano Bivachi on 03/05/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Secret;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * author;
@property (nonatomic, retain) NSNumber * avatar_id;
@property (nonatomic, retain) NSString * comment_id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * i_like_it;
@property (nonatomic, retain) NSNumber * likes_count;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) Secret *secret;

@end
