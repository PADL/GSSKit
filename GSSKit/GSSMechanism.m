//
//  GSSMechanism.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSMechanism
{
    gss_OID _oid;
    gss_OID_desc _oidBuffer;
    NSData *_data;
}

+ (GSSMechanism *)mechanismSPNEGO
{
    return [self mechanismWithOID:GSS_SPNEGO_MECHANISM];
}

+ (GSSMechanism *)mechanismKerberos
{
    return [self mechanismWithOID:GSS_KRB5_MECHANISM];
}

#if 0
+ (GSSMechanism *)mechanismPKU2U
{
    return [self mechanismWithOID:GSS_PKU2U_MECHANISM];
}

+ (GSSMechanism *)mechanismSCRAM
{
    return [self mechanismWithOID:GSS_SCRAM_MECHANISM];
}

+ (GSSMechanism *)mechanismNTLM
{
    return [self mechanismWithOID:GSS_NTLM_MECHANISM];
}

+ (GSSMechanism *)mechanismSASLDigestMD5
{
    return [self mechanismWithOID:GSS_DIGEST_MD5_MECHANISM];
}
#endif

- (GSSMechanism *)initWithOID:(gss_OID)oid
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

+ (GSSMechanism *)mechanismWithOID:(gss_OID)oid
{
    return [[self alloc] initWithOID: oid];
}

+ (GSSMechanism *)mechanismWithDERData: (NSData *)data
{
    return [[self alloc] initWithDERData:data];
}

+ (GSSMechanism *)mechanismWithSASLName: (NSString *)name
{
    OM_uint32 major, minor;
    gss_buffer_desc saslName;
    gss_OID mechType;
    
    saslName = [name _gssBuffer];
    
    major = gss_inquire_mech_for_saslname(&minor, &saslName, &mechType);
    if (GSS_ERROR(major))
        return nil;
    
    return [self mechanismWithOID:mechType];
}

- (gss_const_OID)oid
{
    return _oid;
}

- (NSString *)name
{
    OM_uint32 major, minor;
    gss_buffer_desc buffer = GSS_C_EMPTY_BUFFER;
    
    major = gss_inquire_saslname_for_mech(&minor, _oid,
                                          GSS_C_NO_BUFFER, &buffer, GSS_C_NO_BUFFER);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&buffer];
}

- (NSString *)SASLName
{
    OM_uint32 major, minor;
    gss_buffer_desc buffer = GSS_C_EMPTY_BUFFER;
    
    major = gss_inquire_saslname_for_mech(&minor, _oid,
                                          GSS_C_NO_BUFFER, &buffer, GSS_C_NO_BUFFER);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&buffer];
}

- (NSString *)description
{
    OM_uint32 major, minor;
    gss_buffer_desc buffer = GSS_C_EMPTY_BUFFER;
    
    major = gss_inquire_saslname_for_mech(&minor, _oid,
                                          GSS_C_NO_BUFFER, GSS_C_NO_BUFFER, &buffer);
    if (GSS_ERROR(major))
        return nil;
    
    return [NSString stringWithGSSBuffer:&buffer];
}

@end
