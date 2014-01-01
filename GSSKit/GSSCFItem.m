//
//  GSSCFItem.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

@implementation GSSCFItem

#pragma mark Initialization

+ (void)load
{
    _CFRuntimeBridgeClasses(GSSItemGetTypeID(), "GSSCFItem");
}

+ (id)allocWithZone:(NSZone *)zone
{
    return nil;
}

#pragma mark Bridging

CF_CLASSIMPLEMENTATION(GSSCFItem)

- (NSString *)description
{
    CFStringRef copyDesc = CFCopyDescription((CFTypeRef)self);
    
    return [NSMakeCollectable(copyDesc) autorelease];
}

- (CFTypeID)_cfTypeID
{
    return GSSItemGetTypeID();
}

#pragma mark Wrappers

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error
{
    GSSItemRef res;
    
    res = GSSItemAdd((CFDictionaryRef)attributes, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return [NSMakeCollectable(res) autorelease];
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error
{
    BOOL res;
    
    res = GSSItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes, (CFErrorRef *)error);
    if (error)
        [NSMakeCollectable(*error) autorelease];
    
    return res;
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError * __autoreleasing *)error
{
    BOOL res;
    
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
