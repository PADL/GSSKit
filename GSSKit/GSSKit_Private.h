//
//  GSSKit_Private.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <CoreFoundation/CFBridgingPriv.h>
#import <CoreFoundation/CFRuntime.h>

#import <GSS/gssapi.h>
#import <GSS/gssapi_krb5.h>
#import <GSS/gssapi_spnego.h>

#import "GSSKit.h"
#import "GSSCFItem.h"
#import "GSSCFName.h"
#import "GSSCFCredential.h"
#import "GSSCredential+Private.h"
#import "GSSChannelBindings+Private.h"
#import "GSSMechanism+Private.h"
#import "GSSName+Private.h"
#import "GSSItem_Private.h"
#import "GSSItem+AcquireCredGlue.h"
#import "GSSBuffer.h"

#import "NSError+GSSErrorHelper.h"
#import "NSString+GSSBufferHelper.h"
#import "NSArray+GSSOIDHelper.h"

#undef GSSKIT_EXPORT
#define GSSKIT_EXPORT __attribute__((visibility("default")))

extern NSDictionary *GSSURLSchemeToServiceNameMap;

extern CFStringRef __GSSKitIdentity;
extern dispatch_queue_t __GSSKitBackgroundQueue;

void NSRequestConcreteImplementation(id self, SEL _cmd, Class absClass);

#ifndef GSS_S_PROMPTING_NEEDED
#define GSS_S_PROMPTING_NEEDED (1 << (GSS_C_SUPPLEMENTARY_OFFSET + 5))
#endif

// private interface whilst we have to use gss_set_cred_option for passing dictionary to mech
// this can go away when gss_acquire_cred_ext works
extern NSString * const GSSCredentialName;
extern NSString * const GSSCredentialMechanismOID;

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

GSSAPI_LIB_FUNCTION const char * GSSAPI_LIB_CALL
__ApplePrivate_gss_oid_to_name(gss_const_OID oid);

#define gss_oid_to_name __ApplePrivate_gss_oid_to_name

GSSAPI_LIB_FUNCTION OM_uint32
__ApplePrivate_gss_acquire_cred_ext (
                     OM_uint32 */*minor_status*/,
                     const gss_name_t /*desired_name*/,
                     gss_const_OID /*credential_type*/,
                     const void */*credential_data*/,
                     OM_uint32 /*time_req*/,
                     gss_const_OID /*desired_mech*/,
                     gss_cred_usage_t /*cred_usage*/,
                     gss_cred_id_t */*output_cred_handle*/);

#define gss_acquire_cred_ext __ApplePrivate_gss_acquire_cred_ext

GSSAPI_LIB_FUNCTION OM_uint32
__ApplePrivate_gss_cred_hold(OM_uint32 *min_stat, gss_cred_id_t cred_handle);

#define gss_cred_hold __ApplePrivate_gss_cred_hold

GSSAPI_LIB_FUNCTION OM_uint32
__ApplePrivate_gss_cred_unhold(OM_uint32 *min_stat, gss_cred_id_t cred_handle);

#define gss_cred_unhold __ApplePrivate_gss_cred_unhold

OM_uint32
__ApplePrivate_gss_cred_label_get (
	OM_uint32 * /*min_stat*/,
	gss_cred_id_t /*cred_handle*/,
	const char * /*label*/,
	gss_buffer_t /*value*/);

#define gss_cred_label_get __ApplePrivate_gss_cred_label_get

OM_uint32
__ApplePrivate_gss_cred_label_set (
	OM_uint32 * /*min_stat*/,
	gss_cred_id_t /*cred_handle*/,
	const char * /*label*/,
	gss_buffer_t /*value*/);

#define gss_cred_label_set __ApplePrivate_gss_cred_label_set
