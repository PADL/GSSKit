//
//  GSSCFItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

static id __GSSItemCreate(CFAllocatorRef allocator, NSDictionary *dictionary)
{
    GSSItemRef item;
    
    item = (GSSItemRef)_CFRuntimeCreateInstance(allocator, GSSItemGetTypeID(),
                                                sizeof(struct GSSItem) - sizeof(CFRuntimeBase), NULL);
    if (item == NULL)
        return NULL;
    
    if (dictionary)
        item->keys = CFDictionaryCreateMutableCopy(allocator, 0,
                                                   (CFDictionaryRef)dictionary);
    else
        item->keys = CFDictionaryCreateMutable(allocator, 0,
                                               &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    return (GSSItem *)item;
}

static NSDictionary *__GSSItemGetKeys(GSSCFItem *item)
{
    return (NSDictionary *)((GSSItemRef)item)->keys;
}

static void __GSSItemSetKeys(GSSCFItem *__item, NSDictionary *keys)
{
    GSSItemRef item = (GSSItemRef)__item;
    
    if (item->keys)
        CFRelease(item->keys);
    item->keys = (CFMutableDictionaryRef)CFBridgingRetain([keys mutableCopy]);
}

@implementation GSSCFItem

#pragma mark Initialization

+ (id)allocWithZone:(NSZone *)zone
{
    return __GSSItemCreate(kCFAllocatorDefault, NULL);
}

+ (void)load
{
    _CFRuntimeBridgeClasses(GSSItemGetTypeID(), "GSSCFItem");
}

#pragma mark Bridging

CF_CLASSIMPLEMENTATION(GSSCFItem)

- (CFTypeID)_cfTypeID
{
    return GSSItemGetTypeID();
}

#pragma mark Encoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSSet *codeableKeys = [__GSSItemGetKeys(self) keysOfEntriesPassingTest:^ BOOL (id key, id obj, BOOL *stop) {
        return [obj respondsToSelector:@selector(encodeWithCoder:)];
    }];
    
    NSDictionary *codeableAttrs =
        [[NSDictionary alloc] initWithObjects:[__GSSItemGetKeys(self) objectsForKeys:codeableKeys.allObjects notFoundMarker:[NSNull null]]
                                      forKeys:codeableKeys.allObjects];
    [coder encodeObject:codeableAttrs forKey:@"keys"];
    
    [codeableAttrs release];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSDictionary *itemAttributes;
    
    itemAttributes = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"keys"];
    if (itemAttributes == nil)
        return nil;
    
    __GSSItemSetKeys(self, itemAttributes);
    
    return self;
}

#pragma mark Wrappers

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error
{
    GSSItemRef res;
    
    if (attributes == nil)
        return nil;
    
    res = GSSItemAdd((CFDictionaryRef)attributes, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return [NSMakeCollectable(res) autorelease];
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error
{
    BOOL res;
    
    if (query == nil)
        return NO;
    
    res = GSSItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return res;
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError * __autoreleasing *)error
{
    BOOL res;
    
    if (query == nil)
        return NO;
    
    res = GSSItemDelete((CFDictionaryRef)query, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return res;
}

- (BOOL)delete:(NSError * __autoreleasing *)error
{
    BOOL res;
    
    res = GSSItemDeleteItem((GSSItemRef)self, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return res;
}

+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError * __autoreleasing *)error
{
    NSArray *res;
    
    if (query == nil)
        return nil;
    
    res = (NSArray *)GSSItemCopyMatching((CFDictionaryRef)query, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return res;
}

- (BOOL)_performOperation:(GSSOperation)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(id, NSError *))fun
{
    if (op == kGSSOperationAcquire) {
        // This is a hack to deal with extensible dictionary funnelling
        dispatch_async(__GSSKitBackgroundQueue, ^{
            [self _itemAcquireOperation:options queue:queue completionHandler:fun];
        });

        return YES;
    }
    
    return GSSItemOperation((GSSItemRef)self,
                            op,
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
