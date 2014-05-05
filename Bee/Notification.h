//
//  Notification.h
//  Bee
//
//  Created by Emiliano Bivachi on 29/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * comments_count;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * is_comment;
@property (nonatomic, retain) NSNumber * is_like;
@property (nonatomic, retain) NSNumber * is_new;
@property (nonatomic, retain) NSNumber * likes_count;
@property (nonatomic, retain) NSString * notification_id;
@property (nonatomic, retain) NSString * secret_about;
@property (nonatomic, retain) NSString * secret_content;
@property (nonatomic, retain) NSString * secret_id;
@property (nonatomic, retain) NSString * secret_media_url;
@property (nonatomic, retain) NSString * secret_photo_url;
@property (nonatomic, retain) NSDate * updated_at;

@end
