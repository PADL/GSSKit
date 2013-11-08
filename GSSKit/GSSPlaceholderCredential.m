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

@implementation GSSPlaceholderCredential

#pragma mark Initialization

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
                                desiredName ? [desiredName _gssName] : GSS_C_NO_NAME,
                                credType,
                                credData,
                                timeReq,
                                desiredMech ? [desiredMech oid] : GSS_C_NO_OID,
                                credUsage,
                                (gss_cred_id_t *)pCredHandle);
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
