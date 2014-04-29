//
//  Secret.h
//  Bee
//
//  Created by Emiliano Bivachi on 28/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment;

@interface Secret : NSManagedObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSNumber * author;
@property (nonatomic, retain) NSString * colorFont;
@property (nonatomic, retain) NSNumber * comments_count;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * i_like_it;
@property (nonatomic, retain) NSNumber * likes_count;
@property (nonatomic, retain) NSString * media_url;
@property (nonatomic, retain) NSString * secret_id;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * photo_url;
@property (nonatomic, retain) NSSet *comments;
@end

@interface Secret (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
