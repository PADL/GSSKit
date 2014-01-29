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

@implementation GSSPlaceholderName
+ (id)allocWithZone:(NSZone *)zone
{
    static GSSPlaceholderName *placeholderName;
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
                    error:(NSError * __autoreleasing *)error
{
    gss_name_t name = GSS_C_NO_NAME;
    CFErrorRef cfError = nil;
    
    name = GSSCreateName((__bridge CFDataRef)data, nameType, &cfError);
    if (name == nil) {
        if (error != NULL)
            *error = CFBridgingRelease(cfError);
        else
            CFRelease(cfError);
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

+ (GSSName *)nameWithExportedData:(NSData *)name
{
    NSError *error;

    return [self nameWithData:name nameType:GSS_C_NT_EXPORT_NAME error:&error];
}

+ (GSSName *)nameWithURL:(NSURL *)url
{
    NSString *service;

    service = [GSSURLSchemeToServiceNameMap objectForKey:url.scheme];
    if (service == nil)
        service = url.scheme;
    
    return [self nameWithHostBasedService:service withHostName:url.host];
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

- (NSString *)displayString
{
    CFStringRef description = GSSNameCreateDisplayString([self _gssName]);
    
    return CFBridgingRelease(description);
}

- (BOOL)isEqualToName:(GSSName *)name
{
#if 0
    OM_uint32 major, minor;
    int equal;

    if (name == nil)
        return NO;

    major = gss_compare_name(&minor, [self _gssName], [name _gssName], &equal);
    if (GSS_ERROR(major))
        return NO;

    return equal;
#else
    return [self.displayString isEqualToString:name.displayString];
#endif
}

- (BOOL)isEqual:(id)name
{
    if (name == self)
        return YES;
    else if (![name isKindOfClass:[GSSName class]])
        return NO;
    else
        return [self isEqualToName:name];
}

- (NSUInteger)hash
{
    NSData *data = [self exportName];

    return [data hash];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSData *exportName = [self exportName];

    if (exportName)
        [coder encodeObject:exportName forKey:@"export-name"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSData *exportName;
    GSSName *name = nil;

    exportName = [coder decodeObjectOfClass:[NSData class] forKey:@"export-name"];
    if (exportName) {
        name = [GSSName nameWithExportedData:exportName];
    }

#if !__has_feature(objc_arc)
    [name retain];
#endif

    return name;
}

- (GSSName *)mechanismName:(GSSMechanism *)mechanism
{
    OM_uint32 major, minor;
    gss_name_t mechName;

    major = gss_canonicalize_name(&minor, [self _gssName], (gss_OID)[mechanism oid], &mechName);
    if (GSS_ERROR(major))
        return nil;

    return [GSSCFName nameWithGSSName:mechName freeWhenDone:YES];    
}

@end
