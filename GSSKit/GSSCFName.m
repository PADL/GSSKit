//
//  GSSCFName.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

static CFTypeID _gssNameTypeID;

@implementation GSSCFName

#pragma mark Initialization

+ (void)initialize
{
    CFTypeRef name;
    CFErrorRef error = nil;
    
    name = GSSCreateName(__GSSKitIdentity, GSS_C_NT_USER_NAME, &error);
    NSAssert(name != nil, @"failed to create temporary GSS name");

    _gssNameTypeID = CFGetTypeID((CFTypeRef)name);
    
    if (error)
        CFRelease(error);
    CFRelease(name);
    
    _CFRuntimeBridgeClasses(_gssNameTypeID, "GSSCFName");
}

+ (id)allocWithZone:(NSZone *)zone
{
    return nil;
}

+ (GSSName *)nameWithGSSName:(gss_name_t)name
                freeWhenDone:(BOOL)flag
{
    id newName;

    if (flag)
        newName = (id)name;
    else
        newName = [(id)name retain];

    object_setClass(newName, [GSSCFName class]);

    return NSMakeCollectable([newName autorelease]);
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

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)isEqual:(id)anObject
{
    return CFEqual((CFTypeRef)self, (CFTypeRef)anObject);
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
    return _gssNameTypeID;
}

+ (CFTypeID)_cfTypeID
{
    return _gssNameTypeID;
}

- (gss_name_t)_gssName
{
    return (gss_name_t)self;
}

@end
