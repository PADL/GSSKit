//
//  GSSKit_Private.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit.h"
#import "GSSPlaceholderItem.h"
#import "GSSPlaceholderName.h"
#import "GSSCredential+Private.h"
#import "GSSPlaceholderCredential.h"
#import "GSSItem_Private.h"
#import "GSSBuffer.h"

@interface NSError (GSSKit)
+ (NSError *)GSSError:(OM_uint32)majorStatus :(OM_uint32)minorStatus;
+ (NSError *)GSSError:(OM_uint32)majorStatus;
@end

@interface NSData (GSSKit)
- (gss_buffer_desc)_gssBuffer;
@end

@interface NSString (GSSKit)
+ (NSString *)stringWithGSSBuffer:(gss_buffer_t)buffer;
- (gss_buffer_desc)_gssBuffer;
@end

@interface NSArray (GSSKit)
+ (NSArray *)arrayWithGSSOIDSet:(gss_OID_set)oids;
@end

GSSAPI_LIB_FUNCTION OM_uint32 GSSAPI_LIB_CALL
gss_inquire_mech_for_saslname(OM_uint32 *minor_status,
                              const gss_buffer_t sasl_mech_name,
                              gss_OID *mech_type);

GSSAPI_LIB_FUNCTION OM_uint32 GSSAPI_LIB_CALL
gss_inquire_saslname_for_mech(OM_uint32 *minor_status,
                              const gss_OID desired_mech,
                              gss_buffer_t sasl_mech_name,
                              gss_buffer_t mech_name,
                              gss_buffer_t mech_description);


OM_uint32
__ApplePrivate_gss_acquire_cred_ext (
                     OM_uint32 */*minor_status*/,
                     const gss_name_t /*desired_name*/,
                     gss_const_OID /*credential_type*/,
                     const void */*credential_data*/,
                     OM_uint32 /*time_req*/,
                     gss_const_OID /*desired_mech*/,
                     gss_cred_usage_t /*cred_usage*/,
                     gss_cred_id_t */*output_cred_handle*/);
