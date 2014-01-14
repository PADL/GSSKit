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
    return [self kerberosMechanism];
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

+ (GSSMechanism *)IAKerbMechanism
{
    return [self mechanismWithOID:GSS_IAKERB_MECHANISM];
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
    GSSMechanism *mech = [[self alloc] initWithOID: oid];
    
#if !__has_feature(objc_arc)
    [mech autorelease];
#endif

    return mech;
}

+ (GSSMechanism *)mechanismWithDERData: (NSData *)data
{
    GSSMechanism *mech = [[self alloc] initWithDERData:data];
    
#if !__has_feature(objc_arc)
    [mech autorelease];
#endif

    return mech;
}

typedef struct heim_oid {
    size_t length;
    unsigned *components;
} heim_oid;


int
der_parse_heim_oid (const char *str, const char *sep, heim_oid *data);

int
der_put_oid (unsigned char *p, size_t len,
             const heim_oid *data, size_t *size);

void
der_free_oid (heim_oid *k);

+ (GSSMechanism *)mechanismWithOIDString:(NSString *)oidString
{
    char mechbuf[64];
    size_t mech_len;
    heim_oid heimOid;
    GSSMechanism *mech;
    NSData *data;
    int ret;
    
    if (der_parse_heim_oid([oidString UTF8String], " .", &heimOid))
        return nil;
    
    ret = der_put_oid ((unsigned char *)mechbuf + sizeof(mechbuf) - 1,
                       sizeof(mechbuf),
                       &heimOid,
                       &mech_len);
    if (ret) {
        der_free_oid(&heimOid);
        return nil;
    }

    data = [NSData dataWithBytes:mechbuf + sizeof(mechbuf) - mech_len length:mech_len];
    mech = [self mechanismWithDERData:data];
    der_free_oid(&heimOid);

    return mech;
}

+ (GSSMechanism *)mechanismWithClass:(NSString *)type
{
    GSSMechanism *mech = nil;
    
    if ([type isEqual:(__bridge id)kGSSAttrClassKerberos])
        mech = [self kerberosMechanism];
    else if ([type isEqual:(__bridge id)kGSSAttrClassNTLM])
        mech = [self NTLMMechanism];
    else if ([type isEqual:(__bridge id)kGSSAttrClassIAKerb])
        mech = [self IAKerbMechanism];
    else if (type)
        mech = [self mechanismWithOIDString:type];

    if (mech == nil)
        mech = [self defaultMechanism];
    
    return mech;
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

- (NSString *)mechanismClass
{
    if ([self isKerberosMechanism])
        return (__bridge NSString *)kGSSAttrClassKerberos;
    else if ([self isNTLMMechanism])
        return (__bridge NSString *)kGSSAttrClassNTLM;
    else if ([self isIAKerbMechanism])
        return (__bridge NSString *)kGSSAttrClassIAKerb;
    else if ([self isSPNEGOMechanism])
        return nil; /* pseudo-mechanisms are all classes, potentially */
    else
        return [self oidString];
}

- (NSString *)oidString
{
    OM_uint32 major, minor;
    gss_buffer_desc oidStringBuf = GSS_C_EMPTY_BUFFER;
    NSString *oidString;
    
    major = gss_oid_to_str(&minor, (gss_OID)_oid, &oidStringBuf);
    if (GSS_ERROR(major))
        return nil;
    
    oidString = [NSString stringWithGSSBuffer:&oidStringBuf freeWhenDone:YES];
    return [oidString stringByReplacingOccurrencesOfString:@" " withString:@"."];
}

- (NSString *)name
{
    const char *name = gss_oid_to_name(_oid);
    
    if (name == NULL)
        return [self oidString];
    
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

- (BOOL)isSPNEGOMechanism
{
    return [self isEqualToOID:GSS_SPNEGO_MECHANISM];
}

- (BOOL)isKerberosMechanism
{
    return [self isEqualToOID:GSS_KRB5_MECHANISM];
}

- (BOOL)isNTLMMechanism
{
    return [self isEqualToOID:GSS_NTLM_MECHANISM];
}

- (BOOL)isIAKerbMechanism
{
    return [self isEqualToOID:GSS_IAKERB_MECHANISM];
}

- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[GSSMechanism class]])
        return [self isEqualToOID:[anObject oid]];
    else
        return NO;
}

- (gss_const_OID)oid
{
    return _oid;
}

- (BOOL)isEqualToOID:(gss_const_OID)someOid
{
    return gss_oid_equal(_oid, someOid);
}

@end
