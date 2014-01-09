//
//  GSSCFCredential.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

/* GSS_C_CRED_PASSWORD - 1.2.752.43.13.200 */
static const gss_OID_desc GSSCredPasswordDesc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x48" };

/* GSS_C_CRED_CERTIFICATE - 1.2.752.43.13.201 */
static const gss_OID_desc GSSCredCertificateDesc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x49" };

/* GSS_C_CRED_SecIdentity - 1.2.752.43.13.202 */
static const gss_OID_desc GSSCredSecIdentityDesc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x4a" };

/* GSS_C_CRED_HEIMBASE - 1.2.752.43.13.203 */
static const gss_OID_desc GSSCredHeimbase = { 7, "\x2a\x85\x70\x2b\x0d\x81\x4b" };

/* GSS_SET_CRED_CFDictionary - 1.3.6.1.4.1.5322.25.4.1 */
static const gss_OID_desc GSSSetCredCFDictionary = { 10, "\x2B\x06\x01\x04\x01\xA9\x4A\x19\x04\x01" };

static CFTypeID _gssCredTypeID;

static gss_cred_id_t
__GSSCreateCred(CFAllocatorRef allocator)
{
    OM_uint32 major, minor;
    CFErrorRef error = NULL;
    gss_name_t name = GSSCreateName(__GSSKitIdentity, GSS_C_NT_USER_NAME, &error);
    gss_cred_id_t cred = GSS_C_NO_CREDENTIAL;
    
    major = gss_acquire_cred(&minor, name, GSS_C_INDEFINITE,
                             GSS_C_NO_OID_SET, GSS_C_ACCEPT,
                             &cred, NULL, NULL);

    if (error)
        CFRelease(error);
    CFRelease(name);

    if (GSS_ERROR(major))
        return NULL;
    
    return cred;
}
 
@implementation GSSCFCredential

#pragma mark Initialization

+ (void)load
{
    gss_cred_id_t cred = __GSSCreateCred(kCFAllocatorDefault);
   
    NSAssert(cred != GSS_C_NO_CREDENTIAL, @"failed to initialize cred");

    if (cred) {
        _gssCredTypeID = CFGetTypeID((CFTypeRef)cred);
        CFRelease(cred);
        _CFRuntimeBridgeClasses(_gssCredTypeID, "GSSCFCredential");
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    static id placeholderCred = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (placeholderCred == nil)
            placeholderCred = (id)__GSSCreateCred(kCFAllocatorDefault);
    });

    return placeholderCred;
}

+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred
                            freeWhenDone:(BOOL)flag
{
    id newCred;

    if (cred == GSS_C_NO_CREDENTIAL)
        return nil;
    
    // cred is a CF object, so it needs to be autoreleased
    if (flag)
        newCred = (id)cred;
    else
        newCred = (id)CFRetain(cred);

    NSAssert([newCred class] == [GSSCFCredential class], @"GSSCFCredential class not mapped");

    return [NSMakeCollectable(newCred) autorelease];
}

- (void)destroy
{
    OM_uint32 minor;
    gss_cred_id_t cred = (gss_cred_id_t)[self retain];
    
    gss_destroy_cred(&minor, &cred);
}

#pragma mark Bridging

CF_CLASSIMPLEMENTATION(GSSCFCredential)

- (CFTypeID)_cfTypeID
{
    return _gssCredTypeID;
}

- (gss_cred_id_t)_gssCred
{
    return (gss_cred_id_t)self;
}

@end

OM_uint32
GSSChangePasswordWrapper(GSSName *desiredName,
                         GSSMechanism *desiredMech,
                         NSDictionary *attributes,
                         NSError * __autoreleasing *pError)
{
    OM_uint32 major;
    
    major = gss_aapl_change_password([desiredName _gssName],
                                     [desiredMech oid],
                                     (CFDictionaryRef)attributes,
                                     (CFErrorRef *)pError);
    if (pError != NULL)
        *pError = [NSMakeCollectable(*pError) autorelease];

    return major;
}

static OM_uint32
GSSUsageFromAttributeDictionary(NSDictionary *attributes,
                                gss_cred_usage_t *pCredUsage)
{
    gss_cred_usage_t credUsage;
    NSString *usage;
    
    usage = attributes[GSSCredentialUsage];
    if ([usage isEqualToString:GSSCredentialUsageInitiate])
        credUsage = GSS_C_INITIATE;
    else if ([usage isEqualToString:GSSCredentialUsageAccept])
        credUsage = GSS_C_ACCEPT;
    else if ([usage isEqualToString:GSSCredentialUsageBoth])
        credUsage = GSS_C_BOTH;
    else
        return GSS_S_FAILURE;
    
    *pCredUsage = credUsage;
    return GSS_S_COMPLETE;
}

/*
 * XXX very naughty bug workaround for Heimdal not setting mech cred OID
 */
#include <GSS/GSS.h>
#include "mechqueue.h"

typedef struct gssapi_mech_interface_desc {
    unsigned                        gm_version;
    const char                      *gm_name;
    gss_OID_desc                    gm_mech_oid;
    unsigned                        gm_flags;
    uintptr_t                       gm_pad[58];
} gssapi_mech_interface_desc, *gssapi_mech_interface;

struct _gss_mechanism_cred {
    HEIM_SLIST_ENTRY(_gss_mechanism_cred) gmc_link;
    gssapi_mech_interface   gmc_mech;       /* mechanism ops for MC */
    gss_OID                 gmc_mech_oid;   /* mechanism oid for MC */
    gss_cred_id_t           gmc_cred;       /* underlying MC */
};
HEIM_SLIST_HEAD(_gss_mechanism_cred_list, _gss_mechanism_cred);

struct _gss_cred {
    CFRuntimeBase base;
    struct _gss_mechanism_cred_list gc_mc;
};

extern struct _gss_mech_switch_list _gss_mechs;

static void
__GSSMechanismCredentialPatch(gss_cred_id_t cred)
{
    struct _gss_cred *c = (struct _gss_cred *)cred;
    struct _gss_mechanism_cred *mc;
  
    HEIM_SLIST_FOREACH(mc, &c->gc_mc, gmc_link) {
        if (mc->gmc_mech_oid->elements == NULL) {
            NSLog(@"__GSSMechanismCredentialPatch: patching cred %@", cred);
            mc->gmc_mech_oid = &mc->gmc_mech->gm_mech_oid;
            NSCAssert(mc->gmc_mech_oid->elements != NULL, @"__GSSMechanismCredentialPatch elements check");
            NSCAssert(mc->gmc_mech_oid->length != 0, @"__GSSMechanismCredentialPatch length check");
        }
    }
}

/*
 * this is a variant of gss_aapl_initial_cred() that is more generalised
 */

GSSKIT_EXPORT OM_uint32
GSSAcquireCredFunnel(GSSName *desiredName,
                     GSSMechanism *desiredMech,
                     NSDictionary *attributes,
                     GSSCredential * __autoreleasing *pCredential,
                     NSError * __autoreleasing *pError)
{
    OM_uint32 major = GSS_S_FAILURE, minor = 0;
    gss_cred_usage_t credUsage = GSS_C_INITIATE;
    gss_cred_id_t credHandle = GSS_C_NO_CREDENTIAL;
    gss_buffer_desc credBuffer = GSS_C_EMPTY_BUFFER;
    
    if (pError != NULL)
        *pError = nil;
    *pCredential = nil;
    
    if (desiredMech == nil) {
        major = GSS_S_BAD_MECH;
        goto cleanup;
    }
    
    major = GSSUsageFromAttributeDictionary(attributes, &credUsage);
    if (GSS_ERROR(major))
        goto cleanup;
   
    /*
     * First, try passing the CFDictionary directly to the mechanism, as some
     * mechanisms (for example BrowserID) might use this.
     */ 
#if 0
    major = gss_acquire_cred_ext(&minor,
                                 [desiredName _gssName],
                                 &GSSCredHeimbase,
                                 attributes,
                                 GSS_C_INDEFINITE,
                                 [desiredMech oid],
                                 credUsage,
                                 &credHandle);
#else
    NSMutableDictionary *setCredAttrs = [attributes mutableCopy];
    
    setCredAttrs[GSSCredentialName] = desiredName;
    if (![desiredMech isSPNEGOMechanism])
        setCredAttrs[GSSCredentialMechanismOID] = [desiredMech oidString];
    
    credBuffer.value = (void *)setCredAttrs;
    credBuffer.length = sizeof(setCredAttrs);

    major = gss_set_cred_option(&minor,
                                &credHandle,
                                (gss_OID)&GSSSetCredCFDictionary,
                                &credBuffer);
    
    [setCredAttrs release];
#endif
    if (credHandle == GSS_C_NO_CREDENTIAL) {
        /* try password or certificate fallback */
        id password = attributes[GSSICPassword];
        id certificate = attributes[GSSICCertificate];

        void *credData = NULL;
        gss_const_OID credOid = GSS_C_NO_OID;

        if (password && [password respondsToSelector:@selector(_gssBuffer)]) {
            credBuffer = [password _gssBuffer];
            credOid = &GSSCredPasswordDesc;
            credData = &credBuffer;
        } else if (certificate && CFGetTypeID((CFTypeRef)certificate) == SecIdentityGetTypeID()) {
            credOid = &GSSCredSecIdentityDesc;
            credData = certificate;
        }

        major = gss_acquire_cred_ext(&minor,
                                     [desiredName _gssName],
                                     credOid,
                                     credData,
                                     GSS_C_INDEFINITE,
                                     [desiredMech oid],
                                     credUsage,
                                     &credHandle);
    }
    
    if (GSS_ERROR(major))
        goto cleanup;

    __GSSMechanismCredentialPatch(credHandle);
    
    *pCredential = [GSSCFCredential credentialWithGSSCred:credHandle freeWhenDone:YES];

    if (attributes[GSSICVerifyCredential]) {
        NSError *error = nil;
        
        if (![*pCredential validate:&error]) {
            major = [error.userInfo[GSSMajorErrorCodeKey] unsignedIntValue];

            if (pError != NULL)
                *pError = error;

            goto cleanup;
        }
    }

    credHandle = GSS_C_NO_CREDENTIAL;

cleanup:
    if (GSS_ERROR(major)) {
        if (pError != NULL && *pError == nil)
            *pError = [NSError GSSError:major :minor :desiredMech];
        if (credHandle != GSS_C_NO_CREDENTIAL)
            gss_destroy_cred(&minor, &credHandle);
    }
    
    return major;
}
