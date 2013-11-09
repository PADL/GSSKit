//
//  GSSMechanism.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

static const gss_OID_desc GSSBrowserIDAes128MechDesc =
{ 10, "\x2B\x06\x01\x04\x01\xA9\x4A\x18\x01\x11" };

static const gss_OID_desc GSSBrowserIDAes256MechDesc =
{ 10, "\x2B\x06\x01\x04\x01\xA9\x4A\x18\x01\x12" };

static const gss_OID_desc GSSEapAes128MechDesc =
{ 9, "\x2B\x06\x01\x05\x05\x0f\x01\x01\x11" };

static const gss_OID_desc GSSEapAes256MechDesc =
{ 9, "\x2B\x06\x01\x05\x05\x0f\x01\x01\x12" };

@implementation GSSMechanism
{
    gss_const_OID _oid;
    gss_OID_desc _oidBuffer;
    NSData *_data;
}

+ (GSSMechanism *)defaultMechanism
{
    return [self SPNEGOMechanism];
}

+ (GSSMechanism *)SPNEGOMechanism
{
    return [self mechanismWithOID:GSS_SPNEGO_MECHANISM];
}

+ (GSSMechanism *)kerberosMechanism
{
    return [self mechanismWithOID:GSS_KRB5_MECHANISM];
}

+ (GSSMechanism *)NTLMMechanism
{
    return [self mechanismWithOID:GSS_NTLM_MECHANISM];
}

+ (GSSMechanism *)PKU2UMechanism
{
    return [self mechanismWithOID:GSS_PKU2U_MECHANISM];
}

#if 0
+ (GSSMechanism *)SCRAMMechanism
{
    return [self mechanismWithOID:GSS_SCRAM_MECHANISM];
}
#endif

+ (GSSMechanism *)digestMD5Mechanism
{
    return [self mechanismWithOID:GSS_SASL_DIGEST_MD5_MECHANISM];
}

+ (GSSMechanism *)personaMechanism
{
    return [self mechanismWithOID:&GSSBrowserIDAes128MechDesc];
}

+ (GSSMechanism *)EAPMechanism
{
    return [self mechanismWithOID:&GSSEapAes128MechDesc];
}

- (GSSMechanism *)initWithOID:(gss_const_OID)oid
{
    if ((self = [super init]) != nil)
        _oid = oid;
    
    return self;
}

- (GSSMechanism *)initWithDERData:(NSData *)data
{
    _data = [data copy];
    _oidBuffer.elements = (void *)[data bytes];
    _oidBuffer.length = (OM_uint32)[data length];

    return [self initWithOID:&_oidBuffer];
}

+ (GSSMechanism *)mechanismWithOID:(gss_const_OID)oid
{
    return [[self alloc] initWithOID: oid];
}

+ (GSSMechanism *)mechanismWithDERData: (NSData *)data
{
    return [[self alloc] initWithDERData:data];
}

+ (GSSMechanism *)mechanismWithSASLName: (NSString *)name
{
#if 0
    // XXX why are these not exported from GSS.framework
    OM_uint32 major, minor;
    gss_buffer_desc saslName;
    gss_OID mechType;
    
    saslName = [name _gssBuffer];
    
    major = gss_inquire_mech_for_saslname(&minor, &saslName, &mechType);
    if (GSS_ERROR(major))
        return nil;
    
    return [self mechanismWithOID:mechType];
#else
    if ([name isEqualToString:@"GSSAPI"])
        return [self kerberosMechanism];
    else if ([name isEqualToString:@"GSS-SPNEGO"])
        return [self SPNEGOMechanism];
    else
        return nil;
#endif
}

- (gss_const_OID)oid
{
    return _oid;
}

- (NSString *)oidString
{
    OM_uint32 major, minor;
    gss_buffer_desc oidString = GSS_C_EMPTY_BUFFER;
    
    major = gss_oid_to_str(&minor, (gss_OID)_oid, &oidString);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&oidString freeWhenDone:YES];
}

- (NSString *)name
{
    const char *name = gss_oid_to_name(_oid);
    
    if (name == NULL)
        return nil;
    
    return [NSString stringWithUTF8String:name];    
}

- (NSString *)SASLName
{
#if 0
    OM_uint32 major, minor;
    gss_buffer_desc buffer = GSS_C_EMPTY_BUFFER;
    
    major = gss_inquire_saslname_for_mech(&minor, _oid,
                                          GSS_C_NO_BUFFER, &buffer, GSS_C_NO_BUFFER);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&buffer freeWhenDone:YES];
#else
    if ([self isKerberosMechanism])
        return @"GSSAPI";
    else if ([self isSPNEGOMechanism])
        return @"GSS-SPNEGO";
    else
        return nil;
#endif
}

- (NSString *)description
{
#if 0
    OM_uint32 major, minor;
    gss_buffer_desc buffer = GSS_C_EMPTY_BUFFER;
    
    major = gss_inquire_saslname_for_mech(&minor, _oid,
                                          GSS_C_NO_BUFFER, GSS_C_NO_BUFFER, &buffer);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&buffer];
#else
    return [self name];
#endif
}

- (BOOL)isEqualToOID:(gss_const_OID)someOid
{
    return gss_oid_equal(_oid, someOid);
}

- (BOOL)isSPNEGOMechanism
{
    return [self isEqualToOID:GSS_SPNEGO_MECHANISM];
}

- (BOOL)isKerberosMechanism
{
    return [self isEqualToOID:GSS_KRB5_MECHANISM];
}

- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[GSSMechanism class]])
        return [self isEqualToOID:[anObject oid]];
    else
        return NO;
}

@end
