//
//  GSSItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// GSSItem abstract class

@implementation GSSItem

+ (id)alloc
{
    if ([self isEqual:[GSSItem class]])
        return [GSSPlaceholderItem alloc];
    else
        return [super alloc];
}

+ (id)allocWithZone:(NSZone *)zone
{
    if ([self isEqual:[GSSItem class]])
        return [GSSPlaceholderItem allocWithZone:zone];
    else
        return [super allocWithZone:zone];
}

#pragma mark GSSItem primitive methods

+ (GSSItem *)itemWithAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    return [[self alloc] initWithAttributes:attributes error:error];
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