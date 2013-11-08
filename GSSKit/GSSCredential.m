//
//  GSSCredential.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

static GSSCredential *placeholderCred;

@implementation GSSCredential

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (placeholderCred == nil)
            placeholderCred = [super allocWithZone:zone];
    }
    
    return placeholderCred;
}

+ (GSSCredential *)credentialWithName:(GSSName *)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
                                error:(NSError **)error
{
    return [[self alloc] initWithName:name mechanism:desiredMech attributes:attributes error:error];
}

+ (NSString *)usageFlagsToString:(OM_uint32)flags
{
    NSString *credUsage = nil;
    
    flags &= GSS_C_OPTION_MASK;
    
    switch (flags) {
        case GSS_C_ACCEPT:
            credUsage = (__bridge NSString *)kGSS_C_ACCEPT;
            break;
        case GSS_C_BOTH:
            credUsage = (__bridge NSString *)kGSS_C_BOTH;
            break;
        case GSS_C_INITIATE:
        default:
            credUsage = (__bridge NSString *)kGSS_C_INITIATE;
            break;
    }
    
    return credUsage;
}

+ (GSSCredential *)credentialWithName:(GSSName *)name
                            mechanism:(GSSMechanism *)desiredMech
                           usageFlags:(OM_uint32)flags
                             password:(NSString *)password
                                error:(NSError **)error
{
    NSDictionary *attributes = @{
                                 (__bridge NSString *)kGSSCredentialUsage : [self usageFlagsToString:flags],
                                 (__bridge NSString *)kGSSICPassword : password
                                 };
    
    return [self credentialWithName:name mechanism:desiredMech
                         attributes:attributes error:error];

}

- (instancetype)initWithName:(GSSName *)name
                   mechanism:(GSSMechanism *)desiredMech
                  attributes:(NSDictionary *)attributes
                       error:(NSError **)error
{
    self = nil;
    
    GSSAcquireCred(name, desiredMech, attributes, &self, error);
    
    return self;
}

- (id)init
{
    return [self initWithName:nil mechanism:[GSSMechanism mechanismSPNEGO] attributes:nil error:NULL];
}

- (void)destroy
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
}

+ (GSSCredential *)credentialWithExportedData:(NSData *)data
{
    OM_uint32 major, minor;
    gss_buffer_desc exportedCred = [data _gssBuffer];
    gss_cred_id_t cred = GSS_C_NO_CREDENTIAL;
    GSSCredential *gssCred = nil;
    
    major = gss_import_cred(&minor, &exportedCred, &cred);
    if (GSS_ERROR(major))
        return nil;
    
    gssCred = [self credentialWithGSSCred:cred freeWhenDone:YES];

    return gssCred;
}

+ (GSSCredential *)credentialWithURLCredential:(NSURLCredential *)urlCred
                                     mechanism:(GSSMechanism *)mech
{
    NSMutableDictionary *attributes = nil;
    NSError *error = nil;
    
    if ([urlCred hasPassword])
        attributes[(__bridge const NSString *)kGSSICPassword] = [urlCred password];
    else if ([urlCred identity])
        attributes[(__bridge const NSString *)kGSSICCertificate] = (__bridge id)[urlCred identity];

    return [self credentialWithName:[GSSName nameWithUserName:[urlCred user]]
                          mechanism:mech
                         attributes:attributes
                              error:&error];
}

- (GSSName *)name
{
    OM_uint32 major, minor;
    gss_name_t name = GSS_C_NO_NAME;
    
    major = gss_inquire_cred(&minor, [self _gssCred], &name, NULL, NULL, NULL);
    if (GSS_ERROR(major))
        return nil;
    
    return [GSSName nameWithGSSName:name freeWhenDone:YES];
}

- (OM_uint32)lifetime
{
    OM_uint32 minor;
    OM_uint32 lifetime = 0;
    
    gss_inquire_cred(&minor, [self _gssCred], NULL, &lifetime, NULL, NULL);
    
    return lifetime;
}

- (OM_uint32)credUsage
{
    OM_uint32 minor;
    gss_cred_usage_t usage;
    
    gss_inquire_cred(&minor, [self _gssCred], NULL, NULL, &usage, NULL);
    
    return usage;
}

- (NSArray *)mechanisms
{
    OM_uint32 major, minor;
    gss_OID_set oids = GSS_C_NO_OID_SET;
    NSArray *mechanisms;
    
    major = gss_inquire_cred(&minor, [self _gssCred], NULL, NULL, NULL, &oids);
    if (GSS_ERROR(major) || oids == GSS_C_NO_OID_SET)
        return nil;
    
    mechanisms = [NSArray arrayWithGSSOIDSet:oids];
    
    gss_release_oid_set(&minor, &oids);
    
    return mechanisms;
}

- (NSData *)export
{
    OM_uint32 major, minor;
    gss_buffer_desc exportedCred;
    
    major = gss_export_cred(&minor, [self _gssCred], &exportedCred);
    if (GSS_ERROR(major))
        return nil;
    
    return [GSSBuffer dataWithGSSBufferNoCopy:&exportedCred freeWhenDone:YES];
}


- (void)iterateWithFlags:(OM_uint32)flags ofMechanism:(GSSMechanism *)mech
                callback:(void (^)(GSSMechanism *, GSSCredential *))fun
{
    OM_uint32 major, minor;
    
    major = gss_iter_creds(&minor, flags, [mech oid],
                           ^(gss_iter_OID mechOid, gss_cred_id_t mechCred){
                               GSSMechanism *m = [GSSMechanism mechanismWithOID:mechOid];
                               GSSCredential *c = [GSSCredential credentialWithGSSCred:mechCred freeWhenDone:NO];
                               fun(m, c);
    });
}

- (void)retainCredential
{
    OM_uint32 major, minor;
    
    major = gss_cred_hold(&minor, [self _gssCred]);
}

- (void)releaseCredential
{
    OM_uint32 major, minor;
    
    major = gss_cred_unhold(&minor, [self _gssCred]);
}

@end
