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
    GSS_ABSTRACT_METHOD;
}

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError **)error
{
    GSS_ABSTRACT_METHOD;
}

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    GSS_ABSTRACT_METHOD;
}

+ (BOOL)delete:(NSDictionary *)query error:(NSError **)error
{
    GSS_ABSTRACT_METHOD;
}

- (BOOL)delete:(NSError **)error
{
    GSS_ABSTRACT_METHOD;
}

+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError **)error
{
    GSS_ABSTRACT_METHOD;
}

- (id)valueForKey:(NSString *)key
{
    GSS_ABSTRACT_METHOD;
}
@end

@implementation GSSItem (Private)
- (BOOL)_performOperation:(NSObject *)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(id, NSError *))fun
{
    GSS_ABSTRACT_METHOD;
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
                    completionHandler:^(id o, NSError *e) {
                        object = o;
                        *error = e;
                    }];
    
    if (bResult == NO)
        return nil;
    
    return object;
}
@end
