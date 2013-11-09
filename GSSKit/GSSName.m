//
//  GSSName.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSPlaceholderName : GSSName
@end

static GSSPlaceholderName *placeholderName;

@implementation GSSPlaceholderName
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (placeholderName == nil)
            placeholderName = [super allocWithZone:zone];
    }
    
    return placeholderName;
}
@end

@implementation GSSName

#pragma Primitive methods

- (instancetype)initWithGSSName:(gss_name_t)name
                   freeWhenDone:(BOOL)flag
{
    GSS_ABSTRACT_METHOD;
}

- (gss_name_t)_gssName
{
    GSS_ABSTRACT_METHOD;
}

#pragma Concrete methods

+ (id)allocWithZone:(NSZone *)zone
{
    id ret;
    
    if (self == [GSSItem class])
        ret = [GSSPlaceholderName allocWithZone:zone];
    else
        ret = [super allocWithZone:zone];
    
    return ret;
}

+ (GSSName *)nameWithData:(NSData *)data
                 nameType:(gss_const_OID)nameType
                    error:(NSError **)error
{
    return [[self alloc] initWithData:data nameType:nameType error:error];
}

+ (GSSName *)nameWithGSSName:(gss_name_t)name freeWhenDone:(BOOL)flag
{
    return [[self alloc] initWithGSSName:name freeWhenDone:flag];
}

- (instancetype)init
{
    return [self initWithGSSName:GSS_C_NO_NAME freeWhenDone:YES];
}

- (instancetype)initWithData:(NSData *)data
                    nameType:(gss_const_OID)nameType
                       error:(NSError **)error
{
    gss_name_t name = GSS_C_NO_NAME;
    gss_buffer_desc nameBuf = GSS_C_EMPTY_BUFFER;
    OM_uint32 major, minor;

    if (error != NULL)
        *error = nil;
    
    nameBuf.length = [data length];
    nameBuf.value = (void *)[data bytes];
    
    major = gss_import_name(&minor, &nameBuf, nameType, &name);
    if (GSS_ERROR(major) && error != NULL)
        *error = [NSError GSSError:major :minor];
    
    return [[GSSCFName alloc] initWithGSSName:name freeWhenDone:YES];
}

+ (GSSName *)nameWithHostBasedService:(NSString *)name
{
    NSError *error;

    return [self nameWithData:[name dataUsingEncoding:NSUTF8StringEncoding]
                     nameType:GSS_C_NT_HOSTBASED_SERVICE error:&error];
}

+ (GSSName *)nameWithHostBasedService:(NSString *)service withHostName:(NSString *)hostname
{
    NSString *name;
    
    name = [NSString stringWithFormat:@"%@@%@", service, hostname];
    
    return [self nameWithHostBasedService:name];
}

+ (GSSName *)nameWithUserName:(NSString *)username
{
    NSError *error;
    
    return [self nameWithData:[username dataUsingEncoding:NSUTF8StringEncoding]
                     nameType:GSS_C_NT_USER_NAME error:&error];
}

- (NSData *)exportName
{
    OM_uint32 major, minor;
    gss_buffer_desc exportedName = GSS_C_EMPTY_BUFFER;
    NSData *data;
    
    major = gss_export_name(&minor, [self _gssName], &exportedName);
    if (GSS_ERROR(major))
        return nil;
    
    data = [GSSBuffer dataWithGSSBufferNoCopy:&exportedName freeWhenDone:YES];
    
    return data;
}

- (NSString *)description
{
    OM_uint32 major, minor;
    gss_buffer_desc displayName = GSS_C_EMPTY_BUFFER;
    gss_OID oid;
    
    major = gss_display_name(&minor, [self _gssName], &displayName, &oid);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&displayName freeWhenDone:YES];
}
@end
