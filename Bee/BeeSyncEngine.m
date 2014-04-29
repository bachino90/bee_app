//
//  BeeSyncEngine.m
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSyncEngine.h"
#import "CoreDataController.h"

#import "Secret+Bee.h"
#import "Comment.h"
#import "Notification.h"

@interface BeeSyncEngine ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

NSString * const kBeeSyncEngineInitialCompleteKey = @"BeeSyncEngineInitialSyncCompleted";
NSString * const kBeeSyncEngineSyncCompletedNotificationName = @"BeeSyncEngineSyncCompleted";
NSString * const kBeeSyncEngineSyncFailedNotificationName = @"BeeSyncEngineSyncFailed";
NSString * const kBeeSyncEngineAllSecretCompletedNotificationName = @"BeeSyncEngineSyncAllSecretsCompleted";

@implementation BeeSyncEngine

+ (BeeSyncEngine *)sharedEngine {
    static BeeSyncEngine *engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[BeeSyncEngine alloc]init];
        [BeeAPIClient sharedClient].notificationRecentUpdate = [engine firstNotificationDate];
        [BeeAPIClient sharedClient].notificationLastUpdate = [engine lastNotificationDate];
        //[BeeAPIClient sharedClient].secretRecentUpdate = [engine firstSecretDate];
        //[BeeAPIClient sharedClient].secretLastUpdate = [engine lastSecretDate];
    });
    return engine;
}



- (NSDate *)lastOrFirstSecret:(BOOL)ascending {
    __block NSDate *date = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Secret"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:ascending]]];
    [request setFetchLimit:1];
    [[[CoreDataController sharedInstance] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[CoreDataController sharedInstance]backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject]) {
            date = [[results lastObject] valueForKey:@"created_at"];
        }
    }];
    return date;
}

- (NSDate *)firstSecretDate {
    return [self lastOrFirstSecret:NO];
}

- (NSDate *)lastSecretDate {
    return [self lastOrFirstSecret:YES];
}

- (NSDate *)lastOrFirstNotification:(BOOL)ascending {
    __block NSDate *date = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:ascending]]];
    [request setFetchLimit:1];
    [[[CoreDataController sharedInstance] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[CoreDataController sharedInstance]backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject]) {
            date = [[results lastObject] valueForKey:@"created_at"];
        }
    }];
    return date;
}

- (NSDate *)firstNotificationDate {
    return [self lastOrFirstNotification:NO];
}

- (NSDate *)lastNotificationDate {
    return [self lastOrFirstNotification:YES];
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter) {
        return _dateFormatter;
    }
    
    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return _dateFormatter;
}

- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kBeeSyncEngineInitialCompleteKey]boolValue];
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kBeeSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)executeSyncFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kBeeSyncEngineSyncFailedNotificationName object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        [[CoreDataController sharedInstance] saveBackgroundContext];
        [[CoreDataController sharedInstance] saveMasterContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBeeSyncEngineSyncCompletedNotificationName object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    if ([key isEqualToString:@"created_at"]) {
        NSDate *date = [self.dateFormatter dateFromString:value];
        [managedObject setValue:date forKey:key];
    } else if ([key isEqualToString:@"id"]) {
        NSDictionary *UID = value;
        NSString *id_string =  UID[[[UID allKeys] firstObject]];
        if ([managedObject isKindOfClass:[Secret class]]) {
            [managedObject setValue:id_string forKey:@"secret_id"];
        } else if ([managedObject isKindOfClass:[Comment class]]) {
            [managedObject setValue:id_string forKey:@"comment_id"];
        } else if ([managedObject isKindOfClass:[Notification class]]) {
            [managedObject setValue:id_string forKey:@"notification_id"];
        }
    } else {
        [managedObject setValue:value forKey:key];
        //NSLog(@"%@",managedObject);
    }
}

- (NSManagedObject *)searchManagedObjectForEntity:(NSString *)className withId:(NSString *)object_id {
    if ([className isEqualToString:@"Notification"]) {
        return nil;
    }
    NSManagedObjectContext *moc = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:moc];
    NSPredicate *predicate;
    if ([className isEqualToString:@"Secret"]) {
        predicate = [NSPredicate predicateWithFormat:@"secret_id=%@",object_id];
    } else if ([className isEqualToString:@"Comment"]) {
        predicate = [NSPredicate predicateWithFormat:@"comment_id=%@",object_id];
    } else if ([className isEqualToString:@"Notification"]) {
        predicate = [NSPredicate predicateWithFormat:@"notification_id=%@",object_id];
    }
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error || results == nil || results.count == 0) {
        return nil;
    }
    
    return [results lastObject];
}

- (NSManagedObject *)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    NSDictionary *UID = record[@"id"];
    NSString *id_string =  UID[[[UID allKeys] firstObject]];
    NSManagedObject * managedObject = [self searchManagedObjectForEntity:className withId:id_string];
    if (managedObject) {
        [self updateManagedObject:managedObject withRecord:record];
    } else {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[CoreDataController sharedInstance]backgroundManagedObjectContext]];
        [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self setValue:obj forKey:key forManagedObject:managedObject];
        }];
    }
    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

- (void)saveSecretsToCoreData:(id)responseObject {
    //NSManagedObjectContext *moc = [[CoreDataController sharedInstance]backgroundManagedObjectContext];
    for (NSDictionary *secret in (NSArray *)responseObject) {
        [self newManagedObjectWithClassName:@"Secret" forRecord:secret];
    }
    /*
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unable to save context for Secret");
        }
    }];
     */
    [self executeSyncCompletedOperations];
}

- (void)saveCommentsForSecret:(Secret *)secret toCoreData:(id)responseObject {
    Secret *secretObject = (Secret *)[self searchManagedObjectForEntity:@"Secret" withId:secret.secret_id];
    if (secret == nil) {
        return;
    }
    for (NSDictionary *comment in (NSArray *)responseObject) {
        Comment *commentObject = (Comment *)[self newManagedObjectWithClassName:@"Comment" forRecord:comment];
        [commentObject setValue:CommentSuccessDelivered forKey:@"state"];
        [secretObject addCommentsObject:commentObject];
    }

    [self executeSyncCompletedOperations];
}

- (void)saveNotificationsToCoreData:(id)responseObject {
    //Notification *lastNotification = nil;
    for (NSDictionary *notification in (NSArray *)responseObject) {
        [self newManagedObjectWithClassName:@"Notification" forRecord:notification];
        /*
        if (lastNotification == nil) {
            lastNotification = (Notification *)[self newManagedObjectWithClassName:@"Notification" forRecord:notification];
            //[lastNotification setValue:@(YES) forKey:@"is_new"];
        } else {
            if ([lastNotification.secret_id isEqualToString:notification[@"secret_id"]]) {
                if ([notification[@"is_like"] boolValue]) {
                    [lastNotification setValue:@(YES) forKey:@"is_like"];
                    [lastNotification setValue:@([lastNotification.number_of_likes integerValue]+1) forKey:@"number_of_likes"];
                    //lastNotification.number_of_likes = @([lastNotification.number_of_likes integerValue]+1);
                } else if ([notification[@"is_comment"] boolValue]) {
                    [lastNotification setValue:@(YES) forKey:@"is_comment"];
                    [lastNotification setValue:@([lastNotification.number_of_comments integerValue]+1) forKey:@"number_of_comments"];
                }
            } else {
                lastNotification = (Notification *)[self newManagedObjectWithClassName:@"Notification" forRecord:notification];
            }
        }
         */
    }
    
    [self executeSyncCompletedOperations];
}

- (void)emptyDBSinc:(NSDate *)date {
    NSManagedObjectContext *moc = [[CoreDataController sharedInstance]masterManagedObjectContext];
    
    [moc performBlockAndWait:^{
        NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"Secret" inManagedObjectContext:moc]];
        if (date) {
            NSExpression *exprDate = [NSExpression expressionForKeyPath:@"created_at"];
            NSExpression *exprD = [NSExpression expressionForConstantValue:date];
            NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:exprDate rightExpression:exprD modifier:NSDirectPredicateModifier type:NSLessThanOrEqualToPredicateOperatorType options:0];
            [fetch setPredicate:predicate];
        }
        NSArray *result = [moc executeFetchRequest:fetch error:nil];
        for (id basket in result)
            [moc deleteObject:basket];
        
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unable to save context for Secret");
        }
    }];
}

#pragma mark - Download Methods

- (void)downloadRecentSecrets {
    [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@",responseObject);
            
            if ([BeeAPIClient sharedClient].secretRecentUpdate == nil) {
                //NSDate *firstSecretInDB = [self firstSecretDate];
                //NSDate *today = [NSDate date];
                [self emptyDBSinc:nil];
            }
            [self saveSecretsToCoreData:responseObject];

            [BeeAPIClient sharedClient].secretRecentUpdate = [self firstSecretDate];
            if ([BeeAPIClient sharedClient].secretLastUpdate == nil) {
                [BeeAPIClient sharedClient].secretLastUpdate = [self lastSecretDate];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self executeSyncFailed];
    }];
}

- (void)downloadOldSecrets {
    if ([BeeAPIClient sharedClient].secretLastUpdate == nil) {
        return;
    }
    [[BeeAPIClient sharedClient] GETPastSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@",responseObject);
            [self saveSecretsToCoreData:responseObject];
            
            [BeeAPIClient sharedClient].secretLastUpdate = [self lastSecretDate];
            if (((NSArray *)responseObject).count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kBeeSyncEngineAllSecretCompletedNotificationName object:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self executeSyncFailed];
    }];
}

- (void)downloadRecentCommentsForSecret:(Secret *)secret {
    [[BeeAPIClient sharedClient]GETCommentsForSecret:secret.secret_id success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@",responseObject);
            [self saveCommentsForSecret:secret toCoreData:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self executeSyncFailed];
    }];
}

- (void)downloadOldCommentsForSecret:(Secret *)secret {
    
}

- (void)postComment:(NSDictionary *)comment forSecret:(Secret *)secret {
    Secret *secretObject = (Secret *)[self searchManagedObjectForEntity:@"Secret" withId:secret.secret_id];
    if (secret == nil) {
        return;
    }
    Comment *commentObject = (Comment *)[self newManagedObjectWithClassName:@"Comment" forRecord:comment];
    [commentObject setValue:@(CommentDelivered) forKey:@"state"];
    [commentObject setValue:[NSDate date] forKey:@"created_at"];
    [secretObject addCommentsObject:commentObject];
    
    [self executeSyncCompletedOperations];
    
    __block Comment *comm = commentObject;
    NSDictionary *dictComment = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil];
    [[BeeAPIClient sharedClient]POSTComment:dictComment inSecret:secret.secret_id success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self updateManagedObject:comm withRecord:(NSDictionary *)responseObject];
            [comm setValue:@(CommentSuccessDelivered) forKey:@"state"];
            
            [self executeSyncCompletedOperations];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [comm setValue:@(CommentFailDelivered) forKey:@"state"];

        [self executeSyncCompletedOperations];
    }];
}

- (void)rePostComment:(Comment *)comment forSecret:(Secret *)secret {
    
    Comment *commentObject = (Comment *)[self searchManagedObjectForEntity:@"Comment" withId:comment.comment_id];
    [commentObject setValue:@(CommentDelivered) forKey:@"state"];
    [commentObject setValue:[NSDate date] forKey:@"created_at"];
    
    [self executeSyncCompletedOperations];
    
    __block Comment *comm = commentObject;
    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:comment.content, @"content", nil];
    NSDictionary *dictComment = [NSDictionary dictionaryWithObjectsAndKeys:content, @"comment", nil];
    [[BeeAPIClient sharedClient]POSTComment:dictComment inSecret:secret.secret_id success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self updateManagedObject:comm withRecord:(NSDictionary *)responseObject];
            [comm setValue:@(CommentSuccessDelivered) forKey:@"state"];
            
            [self executeSyncCompletedOperations];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [comm setValue:@(CommentFailDelivered) forKey:@"state"];
        
        [self executeSyncCompletedOperations];
    }];
}

- (void)deleteComment:(Comment *)comment forSecret:(Secret *)secret {
    Secret *secretObject = (Secret *)[self searchManagedObjectForEntity:@"Secret" withId:secret.secret_id];
    if (secret == nil) {
        return;
    }
    Comment *commentObject = (Comment *)[self searchManagedObjectForEntity:@"Comment" withId:comment.comment_id];
    
    if ([commentObject.state integerValue] == CommentSuccessDelivered) {
        //eliminarlo del web service
    }
    
    [secretObject removeCommentsObject:commentObject];
    
    [self executeSyncCompletedOperations];
}

- (void)downloadRecentNotifications {
    [[BeeAPIClient sharedClient]GETRecentNotificationsSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@",responseObject);
            
            [self saveNotificationsToCoreData:responseObject];
            
            [BeeAPIClient sharedClient].notificationRecentUpdate = [self firstNotificationDate];
            if ([BeeAPIClient sharedClient].notificationLastUpdate == nil) {
                [BeeAPIClient sharedClient].notificationLastUpdate = [self lastNotificationDate];
            }
        }
        /*
        NSMutableArray *mutableNotifications = [[NSMutableArray alloc]init];
        int i = 0;
        NSMutableArray *secretIDs = [NSMutableArray array];
        for (NSDictionary *notifications in (NSArray *)responseObject) {
            Notification *notif = [[Notification alloc]initWithDictionary:notifications];
            if (![secretIDs containsObject:notif.secretID]) {
                mutableNotifications[i] = notif;
                secretIDs[i] = notif.secretID;
            } else {
                NSInteger index = [secretIDs indexOfObject:notif.secretID];
                if (notif.isComment) {
                    ((Notification *)[mutableNotifications objectAtIndex:index]).isComment = YES;
                } else if (notif.isLike) {
                    ((Notification *)[mutableNotifications objectAtIndex:index]).isLike = YES;
                }
            }
            i++;
        }
        self.notifications = [mutableNotifications arrayByAddingObjectsFromArray:self.notifications];
        [self.tableView reloadData];
         */
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self executeSyncFailed];
    }];
}

- (void)downloadOldNotifications {
    if ([BeeAPIClient sharedClient].notificationLastUpdate == nil) {
        return;
    }
    [[BeeAPIClient sharedClient]GETOldNotificationsSuccess:^(NSURLSessionDataTask *task, id responseObject) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self executeSyncFailed];
    }];
}

#pragma mark - Public Methods

- (void)startRecentSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadRecentSecrets];
        });
    }
}

- (void)startOldSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadOldSecrets];
        });
    }
}

- (void)startSearchingRecentCommentsForSecret:(Secret *)secret {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadRecentCommentsForSecret:secret];
        });
    }
}

- (void)startSearchingOldCommentsForSecret:(Secret *)secret {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadOldCommentsForSecret:secret];
        });
    }
}

- (void)startPostingComment:(NSDictionary *)comment forSecret:(Secret *)secret {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self postComment:comment forSecret:secret];
        });
    }
}

- (void)startRePostingComment:(Comment *)comment forSecret:(Secret *)secret {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self rePostComment:comment forSecret:secret];
        });
    }
}

- (void)startDeletingComment:(Comment *)comment forSecret:(Secret *)secret {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self deleteComment:comment forSecret:secret];
        });
    }
}

- (void)startSearchingRecentNotifications {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadRecentNotifications];
        });
    }
}

- (void)startSearchingOldNotifications {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadOldNotifications];
        });
    }
}

@end
