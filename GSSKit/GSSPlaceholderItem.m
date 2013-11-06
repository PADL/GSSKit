//
//  GSSItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSPlaceholderItem.h"
#import "GSSItem.h"

@implementation GSSItem

#pragma mark Initialization

+ (GSSItem *)itemWithAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    return [[[self alloc] initWithAttributes:attributes error:error] autorelease];
}

- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    GSSItemRef item;
   
    *error = nil; 
    item = GSSItemAdd((CFDictionaryRef)attributes, (CFErrorRef *)error);

    [self dealloc];
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

- (BOOL)performOperation:(GSSOperation)op
             withOptions:(NSDictionary *)options
           dispatchQueue:(dispatch_queue_t)queue
           callbackBlock:(GSSItemOperationCallbackBlock)fun
{
    return GSSItemOperation((GSSItemRef)self, op, (CFDictionaryRef)options, queue, fun);
}

- (id)valueForKey:(NSString *)key
{
    return GSSItemGetValue((GSSItemRef)self, (CFStringRef)key);
}

@end
