//
//  BeeSyncEngine.m
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSyncEngine.h"
#import "CoreDataController.h"

@interface BeeSyncEngine ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

NSString * const kBeeSyncEngineInitialCompleteKey = @"BeeSyncEngineInitialSyncCompleted";
NSString * const kBeeSyncEngineSyncCompletedNotificationName = @"BeeSyncEngineSyncCompleted";

@implementation BeeSyncEngine

+ (BeeSyncEngine *)sharedEngine {
    static BeeSyncEngine *engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[BeeSyncEngine alloc]init];
        [BeeAPIClient sharedClient].secretRecentUpdate = [engine firstSecretDate];
        [BeeAPIClient sharedClient].secretLastUpdate = [engine lastSecretDate];
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

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        
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
    } else {
        [managedObject setValue:value forKey:key];
    }
}

- (void)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[CoreDataController sharedInstance]backgroundManagedObjectContext]];
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:newManagedObject];
    }];
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

- (void)saveResponseToCoreData:(id)responseObject {
    NSManagedObjectContext *moc = [[CoreDataController sharedInstance]backgroundManagedObjectContext];
    for (NSDictionary *secret in (NSArray *)responseObject) {
        [self newManagedObjectWithClassName:@"Secret" forRecord:secret];
    }
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unable to save context for Secret");
        }
    }];
    [self executeSyncCompletedOperations];
}

- (void)downloadRecentSecrets {
    [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@",responseObject);
            [self saveResponseToCoreData:responseObject];
            
        }
        
        [BeeAPIClient sharedClient].secretRecentUpdate = [self firstSecretDate];
        if ([BeeAPIClient sharedClient].secretLastUpdate == nil) {
            [BeeAPIClient sharedClient].secretLastUpdate = [self lastSecretDate];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)downloadOldSecrets {
    [[BeeAPIClient sharedClient] GETPastSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@",responseObject);
            [self saveResponseToCoreData:responseObject];
            
        }
        
        [BeeAPIClient sharedClient].secretLastUpdate = [self lastSecretDate];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

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

@end
