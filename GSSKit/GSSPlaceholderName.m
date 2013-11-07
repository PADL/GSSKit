//
//  GSSPlaceholderName.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSPlaceholderName

#pragma mark Initialization

- (id)initWithData:(NSData *)data
          nameType:(gss_const_OID)nameType
             error:(NSError **)error
{
    gss_name_t name = GSS_C_NO_NAME;
    gss_buffer_desc nameBuf = GSS_C_EMPTY_BUFFER;
    OM_uint32 major, minor;
    
    [self release];
    
    *error = nil;

    nameBuf.length = [data length];
    nameBuf.value = (void *)[data bytes];
    
    major = gss_import_name(&minor, &nameBuf, nameType, &name);
    if (GSS_ERROR(major))
        *error = [NSError gssError:major :minor];
    
    return (id)name;
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

@end