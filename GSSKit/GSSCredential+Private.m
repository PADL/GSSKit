//
//  GSSCredential+Private.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSCredential+Private.h"

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
                                     GSS_C_CRED_CFDictionary,
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
        gss_OID credOid = GSS_C_NO_OID;
        
        if (password && [password respondsToSelector:@selector(_gssBuffer)]) {
            credBuffer = [password _gssBuffer];
            credOid = GSS_C_CRED_PASSWORD;
            credData = &credBuffer;
        } else if (certificate && CFGetTypeID((CFTypeRef)certificate) == SecIdentityGetTypeID()) {
            credOid = GSS_C_CRED_SecIdentity;
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