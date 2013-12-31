//
//  GSSItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// GSSItem abstract class

@interface GSSPlaceholderItem : GSSItem
@end

static GSSPlaceholderItem *placeholderItem;

@implementation GSSPlaceholderItem
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if (placeholderItem == nil)
            placeholderItem = [super allocWithZone:zone];
    });
    
    return placeholderItem;
}
@end

@implementation GSSItem
+ (id)allocWithZone:(NSZone *)zone
{
    id ret;
    
    if (self == [GSSItem class])
        ret = [GSSPlaceholderItem allocWithZone:zone];
    else
        ret = [super allocWithZone:zone];
    
    return ret;
}

#pragma mark GSSItem primitive methods

- init
{
    NSRequestConcreteImplementation(self, _cmd, [GSSItem class]);
    return nil;
}

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error
{
    return [GSSCFItem add:attributes error:error];
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error
{
    return [GSSCFItem update:query withAttributes:attributes error:error];
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError * __autoreleasing *)error
{
    return [GSSCFItem delete:query error:error];
}

- (BOOL)delete:(NSError * __autoreleasing *)error
{
    NSRequestConcreteImplementation(self, _cmd, [GSSItem class]);
    return NO;
}

+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError * __autoreleasing *)error
{
    return [GSSCFItem copyMatching:query error:error];
}

- (id)valueForKey:(NSString *)key
{
    NSRequestConcreteImplementation(self, _cmd, [GSSItem class]);
    return nil;
}
@end

@implementation GSSItem (Private)
- (BOOL)_performOperation:(GSSOperation)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(id, NSError *))fun
{
    NSRequestConcreteImplementation(self, _cmd, [GSSItem class]);
    return NO;
}

- (BOOL)_performOperationSynchronously:(GSSOperation)op
                          withOptions:(NSDictionary *)options
                               object:(id __autoreleasing *)object
                                error:(NSError * __autoreleasing *)error
{
    BOOL bResult;
    dispatch_queue_t queue = dispatch_queue_create("com.padl.gss.ItemOperationSynchronousQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
   
    if (object != NULL)
        *object = nil; 
    if (error != NULL)
        *error = nil;
    
    bResult = [self _performOperation:op
                          withOptions:options
                                queue:queue
                    completionHandler:^(id o, NSError *e) {
                        if (object != NULL)
                            *object = o;
                        if (error != NULL)
                            *error = e;
                        dispatch_semaphore_signal(semaphore);
                    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return bResult;
}
@end
