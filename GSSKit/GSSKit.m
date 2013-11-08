//
//  GSSKit.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

/* GSS_C_CRED_CFDictionary - 1.3.6.1.4.1.5322.25.1.1 */
gss_OID_desc __gss_c_cred_cfdictionary_oid_desc = { 10, "\x2B\x06\x01\x04\x01\xA9\x4A\x19\x01\x01" };

/* GSS_C_CRED_PASSWORD - 1.2.752.43.13.200 */
gss_OID_desc GSSAPI_LIB_VARIABLE __gss_c_cred_password_oid_desc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x48" };

/* GSS_C_CRED_CERTIFICATE - 1.2.752.43.13.201 */
gss_OID_desc GSSAPI_LIB_VARIABLE __gss_c_cred_certificate_oid_desc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x49" };

/* GSS_C_CRED_SecIdentity - 1.2.752.43.13.202 */
gss_OID_desc GSSAPI_LIB_VARIABLE __gss_c_cred_secidentity_oid_desc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x4a" };


@implementation NSError (GSSKit)

+ (NSError *)GSSError:(OM_uint32)majorStatus
                     :(OM_uint32)minorStatus
{
    return [NSError errorWithDomain:@"org.h5l.GSS" code:(NSInteger)majorStatus userInfo:nil];
}

+ (NSError *)GSSError:(OM_uint32)majorStatus
{
    return [self GSSError:majorStatus :0];
}

@end


@implementation NSData (GSSKit)
- (gss_buffer_desc)_gssBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self length];
    buffer.value = (void *)[self bytes];
    
    return buffer;
}
@end

@implementation NSString (GSSKit)
+ (NSString *)stringWithGSSBuffer:(gss_buffer_t)buffer
{
    NSData *data = [GSSBuffer dataWithGSSBufferNoCopy:buffer freeWhenDone:NO];
    
    return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (gss_buffer_desc)_gssBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    buffer.value = (void *)[self UTF8String];
    
    return buffer;
}
@end

@implementation NSArray (GSSKit)
+ (NSArray *)arrayWithGSSOIDSet:(gss_OID_set)oids
{
    OM_uint32 minor;
    NSMutableArray *array;
    
    array = [NSMutableArray arrayWithCapacity:oids->count];
    
    for (OM_uint32 i = 0; i < oids->count; i++) {
        gss_OID thisOid = &oids->elements[i];
        NSData *derData = [NSData dataWithBytes:thisOid->elements length:thisOid->length];
        GSSMechanism *mech = [GSSMechanism mechanismWithDERData:derData];
        
        [array addObject:mech];
    }
    
    gss_release_oid_set(&minor, &oids);
    
    return array;
}
@end

#if 0
GSSAPI_LIB_FUNCTION OM_uint32 GSSAPI_LIB_CALL
gss_inquire_mech_for_saslname(OM_uint32 *minor_status,
                              const gss_buffer_t sasl_mech_name,
                              gss_OID *mech_type)
{
    return GSS_S_UNAVAILABLE;
}

GSSAPI_LIB_FUNCTION OM_uint32 GSSAPI_LIB_CALL
gss_inquire_saslname_for_mech(OM_uint32 *minor_status,
                              const gss_OID desired_mech,
                              gss_buffer_t sasl_mech_name,
                              gss_buffer_t mech_name,
                              gss_buffer_t mech_description)
{
    return GSS_S_UNAVAILABLE;
}
#endif
