//
//  GSSItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSPlaceholderItem.h"
#import "GSSItem.h"

// GSSItem abstract class

@implementation GSSItem

+ (id)alloc
{
    if ([self isEqual:[GSSItem class]])
        return [GSSPlaceholderItem alloc];
    else return [super alloc];
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
    return [[[self alloc] initWithAttributes:attributes error:error] autorelease];
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
            dispatchQueue:(dispatch_queue_t)queue
            callbackBlock:(void (^)(NSObject *, NSError *))fun
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

// GSSPlaceholderItem concrete CF class wrapper

@implementation GSSPlaceholderItem

#pragma mark Initialization

- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    GSSItemRef item;

    [self release];

    *error = nil;
    item = GSSItemAdd((CFDictionaryRef)attributes, (CFErrorRef *)error);

    [*error autorelease];
    
    return (id)item;
}

#pragma mark Bridging

- (id)retain
{
    return CFRetain((GSSItemRef)self);
}

- (oneway void)release
{
    CFRelease((GSSItemRef)self);
}

- (id)autorelease
{
    return CFAutorelease((GSSItemRef)self);
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((GSSItemRef)self);
}

- (CFTypeID)_cfTypeID
{
    return GSSItemGetTypeID();
}

#pragma mark Wrappers

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError **)error
{
    GSSItem *res;
    
    *error = nil;
    res = (GSSItem *)GSSItemAdd((CFDictionaryRef)attributes, (CFErrorRef *)error);
    [*error autorelease];
    
    return res;
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    BOOL res;
    
    *error = nil;
    res = GSSItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes, (CFErrorRef *)error);
    [*error autorelease];
    
    return res;
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError **)error
{
    BOOL res;
    
    *error = nil;
    res = GSSItemDelete((CFDictionaryRef)query, (CFErrorRef *)error);
    [*error autorelease];
    
    return res;
}

- (BOOL)delete:(NSError **)error
{
    BOOL res;
    
    *error = nil;
    res = GSSItemDeleteItem((GSSItemRef)self, (CFErrorRef *)error);
    [*error autorelease];
    
    return res;
}

+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError **)error
{
    NSArray *res;
    
    *error = nil;
    res = (NSArray *)GSSItemCopyMatching((CFDictionaryRef)query, (CFErrorRef *)error);
    [*error autorelease];
    
    return res;
}

- (BOOL)_performOperation:(NSObject *)op
              withOptions:(NSDictionary *)options
            dispatchQueue:(dispatch_queue_t)queue
            callbackBlock:(void (^)(NSObject *, NSError *))fun
{
    return GSSItemOperation((GSSItemRef)self, (CFTypeRef)op, (CFDictionaryRef)options, queue, (GSSItemOperationCallbackBlock)fun);
}

- (id)valueForKey:(NSString *)key
{
    return GSSItemGetValue((GSSItemRef)self, (CFStringRef)key);
}

@end
