//
//  GSSCFName.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

@implementation GSSCFName

#pragma mark Initialization

+ (id)allocWithZone:(NSZone *)zone
{
    return nil;
}

- (instancetype)initWithGSSName:(gss_name_t)name
                   freeWhenDone:(BOOL)flag
{
    NSAssert(self == nil, @"self must be nil");
    
    if (flag)
        self = (id)name;
    else
        self = [(id)name copy];
    
    return self;
}

#pragma mark Bridging

- (id)retain
{
    return CFRetain((CFTypeRef)self);
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)autorelease
{
    return CFAutorelease((CFTypeRef)self);
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)isEqual:(id)anObject
{
    return (BOOL)CFEqual((CFTypeRef)self, (CFTypeRef)anObject);
}

- (gss_name_t)_gssName
{
    return (gss_name_t)self;
}

@end
