//
//  GSSCredential.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

static const gss_OID_desc
GSSCredValidateOidDesc = { 6, "\x2a\x85\x70\x2b\x0d\x25" }; // XXX

@interface GSSPlaceholderCredential : GSSCredential
@end

@implementation GSSPlaceholderCredential
+ (id)allocWithZone:(NSZone *)zone
{
    static GSSPlaceholderCredential *placeholderCred;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if (placeholderCred == nil)
            placeholderCred = [super allocWithZone:zone];
    });
    
    return placeholderCred;
}
@end

@implementation GSSCredential

+ (id)allocWithZone:(NSZone *)zone
{
    id ret;
    
    if (self == [GSSCredential class])
        ret = [GSSPlaceholderCredential allocWithZone:zone];
    else
        ret = [super allocWithZone:zone];
    
    return ret;
}

+ (GSSCredential *)credentialWithName:(id)name
{
    return [[self alloc] initWithName:name mechanism:[GSSMechanism defaultMechanism] attributes:nil error:NULL];
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
{
    return [[self alloc] initWithName:name mechanism:desiredMech attributes:nil error:NULL];
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
{
    return [[self alloc] initWithName:name mechanism:desiredMech attributes:attributes error:NULL];
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
                                error:(NSError * __autoreleasing *)error
{
    return [[self alloc] initWithName:name mechanism:desiredMech attributes:attributes error:error];
}

+ (NSString *)usageFlagsToString:(uint32_t)flags
{
    NSString *credUsage = nil;
    
    flags &= GSS_C_OPTION_MASK;
    
    switch (flags) {
        case GSS_C_ACCEPT:
            credUsage = GSSCredentialUsageAccept;
            break;
        case GSS_C_BOTH:
            credUsage = GSSCredentialUsageBoth;
            break;
        case GSS_C_INITIATE:
        default:
            credUsage = GSSCredentialUsageInitiate;
            break;
    }
    
    return credUsage;
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           usageFlags:(uint32_t)flags
                             password:(NSString *)password
                                error:(NSError * __autoreleasing *)error
{
    NSDictionary *attributes = @{
                                 GSSCredentialUsage : [self usageFlagsToString:flags],
                                 GSSICPassword : password
                                 };
    
    return [self credentialWithName:name mechanism:desiredMech
                         attributes:attributes error:error];

}

- (id)initWithName:(id)name
         mechanism:(GSSMechanism *)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError * __autoreleasing *)error
{
    self = nil;
    
    if ([name isKindOfClass:[NSString class]]) {
        if ([attributes[GSSCredentialUsage] isEqualToString:GSSCredentialUsageAccept])
            name = [GSSName nameWithHostBasedService:name];
        else
            name = [GSSName nameWithUserName:name];
    } else if ([name isKindOfClass:[NSURL class]]) {
        name = [GSSName nameWithURL:name];
    } else if (![name isKindOfClass:[GSSName class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"-[GSSCredential initWithName:...] requires a NSString, NSURL or GSSName"]
                                     userInfo:nil];
    }
    
    GSSAcquireCredFunnel(name, desiredMech, attributes, &self, error);
    
    return self;
}

- (id)init
{
    return [self initWithName:nil mechanism:[GSSMechanism defaultMechanism] attributes:nil error:NULL];
}

- (void)destroy
{
    NSRequestConcreteImplementation(self, _cmd, [GSSCredential class]);
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
        attributes[GSSICPassword] = [urlCred password];
    else if ([urlCred identity])
        attributes[GSSICCertificate] = (__bridge id)[urlCred identity];

    return [self credentialWithName:[GSSName nameWithUserName:[urlCred user]]
                          mechanism:mech
                         attributes:attributes
                              error:&error];
}

- (GSSName *)name
{
    gss_name_t name = GSSCredentialCopyName([self _gssCred]);
    
    return [GSSName nameWithGSSName:name freeWhenDone:YES];
}

- (uint32_t)lifetime
{
    return GSSCredentialGetLifetime([self _gssCred]);
}

- (uint32_t)credUsage
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

- (NSData *)labelForKey:(NSString *)key
{
    OM_uint32 major, minor;
    gss_buffer_desc labelData;

    major = gss_cred_label_get(&minor, [self _gssCred], [key UTF8String], &labelData);
    if (GSS_ERROR(major))
        return nil;

    return [GSSBuffer dataWithGSSBufferNoCopy:&labelData freeWhenDone:YES];
}

- (void)setLabel:(NSData *)label forKey:(NSString *)key
{
    OM_uint32 minor;
    gss_buffer_desc labelData = [label _gssBuffer];

    gss_cred_label_set(&minor, [self _gssCred], [key UTF8String], &labelData);
}

- (void)iterateWithFlags:(uint32_t)flags ofMechanism:(GSSMechanism *)mech
                callback:(void (^)(GSSMechanism *, GSSCredential *))fun
{
    OM_uint32 minor;
    
    gss_iter_creds(&minor, flags, [mech oid],
                   ^(gss_iter_OID mechOid, gss_cred_id_t mechCred){
                       GSSMechanism *m = [GSSMechanism mechanismWithOID:mechOid];
                       GSSCredential *c = [GSSCredential credentialWithGSSCred:mechCred freeWhenDone:NO];
                       fun(m, c);
    });
}

- (BOOL)validate
{
    return [self validate:NULL];
}

- (BOOL)validate:(NSError * __autoreleasing *)pError
{
    OM_uint32 major, minor;
    gss_buffer_set_t bufferSet = GSS_C_NO_BUFFER_SET;
    
    major = gss_inquire_cred_by_oid(&minor, [self _gssCred],
                                    (gss_OID)&GSSCredValidateOidDesc,
                                    &bufferSet);
 
    if (pError != NULL && GSS_ERROR(major))
        *pError = [NSError GSSError:major :minor];

    gss_release_buffer_set(&minor, &bufferSet);
    
    return !GSS_ERROR(major);
}

- (void)retainCredential
{
    OM_uint32 minor;
    
    gss_cred_hold(&minor, [self _gssCred]);
}

- (void)releaseCredential
{
    OM_uint32 minor;
    
    gss_cred_unhold(&minor, [self _gssCred]);
}

@end
