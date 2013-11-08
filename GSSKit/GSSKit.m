//
//  GSSKit.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

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
