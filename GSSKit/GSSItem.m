//
//  GSSItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// GSSItem abstract class

static GSSItem *placeholderItem;

@implementation GSSItem

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (placeholderItem == nil)
            placeholderItem = [super allocWithZone:zone];
    }
    
    return placeholderItem;
}

#pragma mark GSSItem primitive methods

+ (GSSItem *)itemWithAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    return [[self alloc] initWithAttributes:attributes error:error];
}

- init
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return nil;
}

- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return nil;
}

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return nil;
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return NO;
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return NO;
}

- (BOOL)delete:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return NO;
}

+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return nil;
}

- (BOOL)_performOperation:(NSObject *)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(NSObject *, NSError *))fun
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return NO;
}

- (id)valueForKey:(NSString *)key
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return nil;
}
@end

@implementation GSSItem (Private)
- (BOOL)_performOperation:(NSObject *)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(NSObject *, NSError *))fun
{
    NSAssert(NO, @"Must implement a complete subclass of GSSItem");
    return NO;
}

- (id)_performOperationSynchronously:(const NSObject *)op
                         withOptions:(NSDictionary *)options
                               error:(NSError **)error
{
    BOOL bResult;
    __block id object = nil;
    dispatch_queue_t queue = dispatch_queue_create("com.padl.GSSItemOperationQueue", NULL);
    
    *error = nil;
    
    bResult = [self _performOperation:op
                          withOptions:options
                                queue:queue
                    completionHandler:^(NSObject *o, NSError *e) {
                        object = o;
                        *error = e;
                    }];
    
    if (bResult == NO)
        return nil;
    
    return object;
}
@end