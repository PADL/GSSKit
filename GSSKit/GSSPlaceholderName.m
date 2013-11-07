//
//  GSSPlaceholderName.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

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

#pragma make Concrete

- (NSData *)exportName
{
    OM_uint32 major, minor;
    gss_buffer_desc exportedName = GSS_C_EMPTY_BUFFER;
    NSData *data;
    
    major = gss_export_name(&minor, (gss_name_t)self, &exportedName);
    if (GSS_ERROR(major))
        return nil;
    
    data = [NSData dataWithGSSBuffer:&exportedName];
    
    gss_release_buffer(&minor, &exportedName);
    
    return data;
}

- (NSString *)description
{
    OM_uint32 major, minor;
    gss_buffer_desc displayName = GSS_C_EMPTY_BUFFER;
    NSString *desc;
    gss_OID oid;
    
    major = gss_display_name(&minor, (gss_name_t)self, &displayName, &oid);
    if (GSS_ERROR(major))
        return nil;
    
    desc = [NSString stringWithGSSBuffer:&displayName];
    
    gss_release_buffer(&minor, &displayName);
    
    return desc;
}

@end
