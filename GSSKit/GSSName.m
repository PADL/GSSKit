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
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if (placeholderName == nil)
            placeholderName = [super allocWithZone:zone];
    });
    
    return placeholderName;
}

@end

@implementation GSSName

#pragma Primitive methods

- (gss_name_t)_gssName
{
    NSRequestConcreteImplementation(self, _cmd, [GSSName class]);
    return GSS_C_NO_NAME;
}

+ (GSSName *)nameWithData:(NSData *)data
                 nameType:(gss_const_OID)nameType
                    error:(NSError **)error
{
    gss_name_t name = GSS_C_NO_NAME;
    CFErrorRef cfError = nil;
    
    name = GSSCreateName((__bridge CFDataRef)data, nameType, &cfError);
    if (name == nil) {
        *error = (__bridge_transfer NSError *)cfError;
        return nil;
    }

    return [GSSCFName nameWithGSSName:name freeWhenDone:YES];    
}

+ (GSSName *)nameWithGSSName:(gss_name_t)name freeWhenDone:(BOOL)flag
{
    return [GSSCFName nameWithGSSName:name freeWhenDone:flag];
}

#pragma Concrete methods

+ (id)allocWithZone:(NSZone *)zone
{
    id ret;
    
    if (self == [GSSName class])
        ret = [GSSPlaceholderName allocWithZone:zone];
    else
        ret = [super allocWithZone:zone];
    
    return ret;
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

+ (GSSName *)nameWithExportedName:(NSData *)name
{
    NSError *error;

    return [self nameWithData:name nameType:GSS_C_NT_EXPORT_NAME error:&error];
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
    CFStringRef description = GSSNameCreateDisplayString([self _gssName]);
    
    return (__bridge_transfer NSString *)description;
}

@end
