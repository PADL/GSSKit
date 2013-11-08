//
//  GSSCredential+Private.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSCredential+Private.h"

/* GSS_C_CRED_PASSWORD - 1.2.752.43.13.200 */
static const gss_OID_desc GSSCredPasswordDesc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x48" };

/* GSS_C_CRED_CERTIFICATE - 1.2.752.43.13.201 */
static const gss_OID_desc GSSCredCertificateDesc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x49" };

/* GSS_C_CRED_SecIdentity - 1.2.752.43.13.202 */
static const gss_OID_desc GSSCredSecIdentityDesc = { 7, "\x2a\x85\x70\x2b\x0d\x81\x4a" };

/* GSS_C_CRED_CFDictionary - 1.3.6.1.4.1.5322.25.1.1 */
static const gss_OID_desc GSSCredCFDictionary = { 10, "\x2B\x06\x01\x04\x01\xA9\x4A\x19\x01\x01" };

@implementation GSSCredential (Private)

+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred
                            freeWhenDone:(BOOL)flag
{
    return [[self alloc] initWithGSSCred:cred freeWhenDone:flag];
}

- (instancetype)initWithGSSCred:(gss_cred_id_t)cred
                   freeWhenDone:(BOOL)flag
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
    return nil;
}

- (gss_cred_id_t)_gssCred
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
    return nil;
}

@end

static OM_uint32
GSSUsageFromAttributeDictionary(NSDictionary *attributes,
                                gss_cred_usage_t *pCredUsage)
{
    gss_cred_usage_t credUsage;
    NSString *usage;
    
    usage = [attributes objectForKey:(NSString *)kGSSCredentialUsage];
    if ([usage isEqualToString:(NSString *)kGSS_C_INITIATE])
        credUsage = GSS_C_INITIATE;
    else if ([usage isEqualToString:(NSString *)kGSS_C_ACCEPT])
        credUsage = GSS_C_ACCEPT;
    else if ([usage isEqualToString:(NSString *)kGSS_C_BOTH])
        credUsage = GSS_C_BOTH;
    else
        return GSS_S_FAILURE;
    
    *pCredUsage = credUsage;
    return GSS_S_COMPLETE;
}

OM_uint32
GSSAcquireCred(GSSName *desiredName,
               GSSMechanism *desiredMech,
               NSDictionary *attributes,
               GSSCredential **pCredential,
               NSError **pError)
{
    OM_uint32 major, minor;
    gss_cred_usage_t credUsage = GSS_C_INITIATE;
    GSSCredential *credHandle = nil;
    
    if (pError != NULL)
        *pError = nil;
    *pCredential = nil;
    
    if (desiredMech == nil) {
        major = GSS_S_BAD_MECH;
        goto cleanup;
    }
    if (desiredName == nil) {
        major = GSS_S_BAD_NAME;
        goto cleanup;
    }
    
    major = GSSUsageFromAttributeDictionary(attributes, &credUsage);
    if (GSS_ERROR(major))
        goto cleanup;
    
    major = GSSAcquireCredExtWrapper(&minor,
                                     desiredName,
                                     &GSSCredCFDictionary,
                                     (__bridge const void *)attributes,
                                     GSS_C_INDEFINITE,
                                     desiredMech,
                                     credUsage,
                                     &credHandle);
    if (major == GSS_S_FAILURE || major == GSS_S_UNAVAILABLE) {
        /* try password or certificate fallback */
        id password = [attributes objectForKey:(NSString *)kGSSICPassword];
        id certificate = [attributes objectForKey:(NSString *)kGSSICCertificate];
        gss_buffer_desc credBuffer = GSS_C_EMPTY_BUFFER;
        void *credData = NULL;
        gss_const_OID credOid = GSS_C_NO_OID;
        
        if (password && [password respondsToSelector:@selector(_gssBuffer)]) {
            credBuffer = [password _gssBuffer];
            credOid = &GSSCredPasswordDesc;
            credData = &credBuffer;
        } else if (certificate && CFGetTypeID((CFTypeRef)certificate) == SecIdentityGetTypeID()) {
            credOid = &GSSCredSecIdentityDesc;
            credData = (__bridge void *)certificate;
        }
        
        if (credOid == GSS_C_NO_OID) {
            major = GSS_S_UNAVAILABLE;
            goto cleanup;
        }
        major = GSSAcquireCredExtWrapper(&minor,
                                         desiredName,
                                         credOid,
                                         credData,
                                         GSS_C_INDEFINITE,
                                         desiredMech,
                                         credUsage,
                                         &credHandle);
    }
    if (GSS_ERROR(major))
        goto cleanup;
    
    *pCredential = credHandle;
    credHandle = nil;
    
cleanup:
    if (GSS_ERROR(major) && pError != NULL)
        *pError = [NSError GSSError:major :minor];
    
    return major;
}