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

static gss_name_t
__GSSCreateName(CFAllocatorRef allocator)
{
    gss_name_t name;
    CFErrorRef error = NULL;

    name = GSSCreateName(__GSSKitIdentity, GSS_C_NT_USER_NAME, &error);

    if (error)
        CFRelease(error);

    return name;
}

@implementation GSSCFName

#pragma mark Initialization

+ (void)load
{
    CFTypeRef name;
    
    name = __GSSCreateName(kCFAllocatorDefault);
    NSAssert(name != nil, @"failed to create temporary GSS name");

    _gssNameTypeID = CFGetTypeID((CFTypeRef)name);
    
    CFRelease(name);
    _CFRuntimeBridgeClasses(_gssNameTypeID, "GSSCFName");
}

+ (id)allocWithZone:(NSZone *)zone
{
    static id placeholderName = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (placeholderName == nil)
            placeholderName = (id)__GSSCreateName(kCFAllocatorDefault);
    });

    return placeholderName;
}

+ (GSSName *)nameWithGSSName:(gss_name_t)name
                freeWhenDone:(BOOL)freeWhenDone
{
    id newName;

    if (freeWhenDone)
        newName = (id)name;
    else
        newName = (id)CFRetain(name);

    NSAssert([newName class] == [GSSCFName class], @"GSSCFName class not mapped");

    return [NSMakeCollectable(newName) autorelease];
}

#pragma mark Bridging

CF_CLASSIMPLEMENTATION(GSSCFName)

- (CFTypeID)_cfTypeID
{
    return _gssNameTypeID;
}

- (gss_name_t)_gssName
{
    return (gss_name_t)self;
}

- (id)copyWithZone:(NSZone *)zone
{
    OM_uint32 major, minor;
    gss_name_t copyName = nil;

    /* XXX would it be simpler to return [self retain]? */
    major = gss_duplicate_name(&minor, (__bridge gss_name_t)self, &copyName);
    if (GSS_ERROR(major))
        return nil;

    return (__bridge id)copyName;
}

@end
