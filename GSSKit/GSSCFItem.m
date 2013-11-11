//
//  GSSCFItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

static GSSItem *
__GSSItemToObjCClass(GSSItemRef obj)
{
    GSSItem *item = (GSSItem *)obj;
    object_setClass(item, [GSSCFItem class]);
    return NSMakeCollectable([item autorelease]);
}

@implementation GSSCFItem

#pragma mark Initialization

+ (void)initialize
{
    _CFRuntimeBridgeClasses(GSSItemGetTypeID(), "GSSCFItem");
}

+ (id)allocWithZone:(NSZone *)zone
{
    return nil;
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

- (NSUInteger)retainCount
{
    return CFGetRetainCount((GSSItemRef)self);
}

- (BOOL)isEqual:(id)anObject
{
    return (BOOL)CFEqual((CFTypeRef)self, (CFTypeRef)anObject);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (NSString *)description
{
    CFStringRef copyDesc = CFCopyDescription((CFTypeRef)self);
    
    return NSMakeCollectable([(NSString *)copyDesc autorelease]);
}

- (BOOL)allowsWeakReference
{
    return !_CFIsDeallocating(self);
}

- (BOOL)retainWeakReference
{
    return _CFTryRetain(self) != nil;
}

- (CFTypeID)_cfTypeID
{
    return GSSItemGetTypeID();
}

+ (CFTypeID)_cfTypeID
{
    return GSSItemGetTypeID();
}

#pragma mark Wrappers

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError **)error
{
    GSSItemRef res;
    
    res = GSSItemAdd((CFDictionaryRef)attributes, (CFErrorRef *)error);
    if (error)
        NSMakeCollectable([*error autorelease]);
    
    return __GSSItemToObjCClass(res);
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    BOOL res;
    
    res = GSSItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes, (CFErrorRef *)error);
    if (error)
        NSMakeCollectable([*error autorelease]);
    
    return res;
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError **)error
{
    BOOL res;
    
    res = GSSItemDelete((CFDictionaryRef)query, (CFErrorRef *)error);
    if (error)
        NSMakeCollectable([*error autorelease]);
    
    return res;
}

- (BOOL)delete:(NSError **)error
{
    BOOL res;
    
    res = GSSItemDeleteItem((GSSItemRef)self, (CFErrorRef *)error);
    if (error)
        NSMakeCollectable([*error autorelease]);
    
    return res;
}

+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError **)error
{
    NSArray *res;
    NSEnumerator *e;
    id anItem;
    
    res = (NSArray *)GSSItemCopyMatching((CFDictionaryRef)query, (CFErrorRef *)error);
    if (res) {
        e = [res objectEnumerator];
        while ((anItem = [e nextObject]) != nil) {
            if ([anItem respondsToSelector:@selector(_cfTypeID)] &&
                [anItem _cfTypeID] == GSSItemGetTypeID())
                __GSSItemToObjCClass((GSSItemRef)anItem);
        }
    }
    
    if (error)
        NSMakeCollectable([*error autorelease]);
    
    return res;
}

- (BOOL)_performOperation:(NSObject *)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(id, NSError *))fun
{
    return GSSItemOperation((GSSItemRef)self,
                            (CFTypeRef)op,
                            (CFDictionaryRef)options,
                            queue,
                            ^(CFTypeRef result, CFErrorRef err) {
                                fun((id)result, (NSError *)err);
                            });
}

- (id)valueForKey:(NSString *)key
{
    return GSSItemGetValue((GSSItemRef)self, (CFStringRef)key);
}

@end
