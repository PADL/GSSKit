//
//  GSSPlaceholderCredential.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

/*
 * this is a variant of gss_aapl_initial_cred() that is more generalised
 */

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
GSSAcquireCredExtWrapper(OM_uint32 *minor,
                         GSSName *desiredName,
                         gss_const_OID credType,
                         const void *credData,
                         OM_uint32 timeReq,
                         GSSMechanism *desiredMech,
                         gss_cred_usage_t credUsage,
                         GSSCredential **pCredHandle)
{
    return gss_acquire_cred_ext(minor,
                                [desiredName _gssName],
                                credType,
                                credData,
                                timeReq,
                                [desiredMech oid],
                                credUsage,
                                (gss_cred_id_t *)pCredHandle);
}

static OM_uint32
GSSInitialCred(GSSName *desiredName,
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

    major = GSSAcquireCredExtWrapper(&minor, desiredName,
                                     GSS_C_CRED_CFDictionary, attributes,
                                     GSS_C_INDEFINITE, desiredMech,
                                     credUsage, &credHandle);
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
            credData = certificate;
        }

        if (credOid == GSS_C_NO_OID) {
            major = GSS_S_UNAVAILABLE;
            goto cleanup;
        }
        major = GSSAcquireCredExtWrapper(&minor, desiredName,
                                         credOid, credData,
                                         GSS_C_INDEFINITE, desiredMech,
                                         credUsage, &credHandle);
    }
    if (GSS_ERROR(major))
        goto cleanup;

    *pCredential = credHandle;
    
cleanup:
    if (GSS_ERROR(major) && pError != NULL)
        *pError = [NSError GSSError:major :minor];
    
    return major;
}

OM_uint32
GSSChangePasswordWrapper(GSSName *desiredName,
                         GSSMechanism *desiredMech,
                         NSDictionary *attributes,
                         NSError **pError)
{
    OM_uint32 major;
    CFErrorRef error = NULL;
    
    major = gss_aapl_change_password([desiredName _gssName],
                                     [desiredMech oid],
                                     (CFDictionaryRef)attributes,
                                     &error);
    
    return major;
}

@implementation GSSPlaceholderCredential

#pragma mark Initialization

- (instancetype)initWithName:(GSSName *)name
                   mechanism:(GSSMechanism *)desiredMech
                  attributes:(NSDictionary *)attributes
                       error:(NSError **)error
{
    [self release];
    self = nil;
    
    GSSInitialCred(name, desiredMech, attributes, &self, error);
    
    return self;
}

- (instancetype)initWithGSSCred:(gss_cred_id_t)cred
                   freeWhenDone:(BOOL)flag
{
    [self release];
    if (!flag)
        CFRetain((CFTypeRef)cred);
    self = (id)cred;
    return self;
}

#pragma mark Bridging

- (void)destroy
{
    OM_uint32 minor;
    gss_cred_id_t cred = (gss_cred_id_t)[self retain];
    
    gss_destroy_cred(&minor, &cred);
}

- (id)retain
{
    return CFRetain((CFTypeRef)self);
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)autorelease
{
    return CFAutorelease((CFTypeRef)self);
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)isEqual:(id)anObject
{
    return (BOOL)CFEqual((CFTypeRef)self, (CFTypeRef)anObject);
}

- (gss_cred_id_t)_gssCred
{
    return (gss_cred_id_t)self;
}

@end
