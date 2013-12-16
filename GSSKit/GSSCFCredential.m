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

/* GSS_C_CRED_CFDictionary - 1.3.6.1.4.1.5322.25.1.1 */
static const gss_OID_desc GSSCredCFDictionary = { 10, "\x2B\x06\x01\x04\x01\xA9\x4A\x19\x01\x01" };

static CFTypeID _gssCredTypeID;

@implementation GSSCFCredential

#pragma mark Initialization

+ (void)load
{
    OM_uint32 major, minor;
    CFErrorRef error = NULL;
    gss_name_t name = GSSCreateName(__GSSKitIdentity, GSS_C_NT_USER_NAME, &error);
    gss_cred_id_t cred;
    
    major = gss_acquire_cred(&minor, name, GSS_C_INDEFINITE,
                             GSS_C_NO_OID_SET, GSS_C_ACCEPT,
                             &cred, NULL, NULL);
    
    NSAssert(cred != GSS_C_NO_CREDENTIAL, @"failed to initialize cred");
    
    if (major == GSS_S_COMPLETE) {
        _gssCredTypeID = CFGetTypeID((CFTypeRef)cred);
        CFRelease(cred);
        _CFRuntimeBridgeClasses(_gssCredTypeID, "GSSCFCredential");
    }
    
    if (error != NULL)
        CFRelease(error);
}

+ (id)allocWithZone:(NSZone *)zone
{
    return nil;
}

+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred
                            freeWhenDone:(BOOL)flag
{
    id newCred;

    // cred is a CF object, so it needs to be autoreleased
    if (flag)
        newCred = (id)cred;
    else
        newCred = (id)CFRetain(cred);

    NSAssert([newCred class] == [GSSCFCredential class], @"GSSCFCredential class not mapped");

    return CFBridgingRelease(newCred);
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

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)isEqual:(id)anObject
{
    return (BOOL)CFEqual((CFTypeRef)self, (CFTypeRef)anObject);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (NSString *)description
{
    CFStringRef copyDesc = CFCopyDescription((CFTypeRef)self);
    
    return CFBridgingRelease(copyDesc);
}

- (BOOL)allowsWeakReference
{
    return !_CFIsDeallocating(self);
}

- (BOOL)retainWeakReference
{
    return _CFTryRetain(self) != nil;
}

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
    CFErrorRef error = NULL;
    
    major = gss_aapl_change_password([desiredName _gssName],
                                     [desiredMech oid],
                                     (CFDictionaryRef)attributes,
                                     &error);
    
    if (error != NULL) {
        if (pError != NULL)
            *pError = CFBridgingRelease(error);
        else
            CFRelease(error);
    }

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
 * this is a variant of gss_aapl_initial_cred() that is more generalised
 */

OM_uint32
GSSAcquireCredFunnel(GSSName *desiredName,
                     GSSMechanism *desiredMech,
                     NSDictionary *attributes,
                     GSSCredential * __autoreleasing *pCredential,
                     NSError * __autoreleasing *pError)
{
    OM_uint32 major, minor;
    gss_cred_usage_t credUsage = GSS_C_INITIATE;
    gss_cred_id_t credHandle = GSS_C_NO_CREDENTIAL;
    
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
    major = gss_acquire_cred_ext(&minor,
                                 [desiredName _gssName],
                                 &GSSCredCFDictionary,
                                 attributes,
                                 GSS_C_INDEFINITE,
                                 [desiredMech oid],
                                 credUsage,
                                 &credHandle);
    if (major == GSS_S_FAILURE || major == GSS_S_UNAVAILABLE) {
        /* try password or certificate fallback */
        id password = attributes[GSSICPassword];
        id certificate = attributes[GSSICCertificate];
        gss_buffer_desc credBuffer = GSS_C_EMPTY_BUFFER;
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
        
        if (credOid != GSS_C_NO_OID) {
            major = gss_acquire_cred_ext(&minor,
                                         [desiredName _gssName],
                                         credOid,
                                         credData,
                                         GSS_C_INDEFINITE,
                                         [desiredMech oid],
                                         credUsage,
                                         &credHandle);
        } else {
            gss_OID_set_desc desiredMechs = { 1, (gss_OID)[desiredMech oid] };
            
            major = gss_acquire_cred(&minor,
                                     [desiredName _gssName],
                                     GSS_C_INDEFINITE,
                                     &desiredMechs,
                                     credUsage,
                                     (gss_cred_id_t *)&credHandle,
                                     NULL,
                                     NULL);
        }
    }
    
    if (GSS_ERROR(major))
        goto cleanup;

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
        if (pError != NULL && *pError != nil)
            *pError = [NSError GSSError:major :minor :desiredMech];
        if (credHandle != GSS_C_NO_CREDENTIAL)
            gss_destroy_cred(&minor, &credHandle);
    }
    
    return major;
}
