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

static GSSCredential *
GSSCredentialWithName(id name,
                      GSSMechanism *desiredMech,
                      NSDictionary *attributes,
                      NSError * __autoreleasing *error)
{
    GSSCredential *cred;

    if (name == nil) {
        return nil;
    } else if ([name isKindOfClass:[NSString class]]) {
        if ([[attributes objectForKey:GSSCredentialUsage] isEqualToString:GSSCredentialUsageAccept])
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
    
    cred = GSSAcquireCredFunnel(name, desiredMech, attributes, error);
  
    return cred;
}

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
    return [self credentialWithName:name mechanism:[GSSMechanism defaultMechanism]];
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
{
    NSDictionary *attributes = @{
                                 GSSCredentialUsage: GSSCredentialUsageInitiate
                                 };

    return [self credentialWithName:name mechanism:desiredMech attributes:attributes];
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
{
    return [self credentialWithName:name mechanism:desiredMech attributes:attributes error:NULL];
}

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
                                error:(NSError * __autoreleasing *)error
{
    GSSCredential *cred = GSSCredentialWithName(name, desiredMech, attributes, error);
    
#if !__has_feature(objc_arc)
    [cred autorelease];
#endif

    return cred;
}

+ (GSSCredential *)credentialWithUUID:(NSUUID *)uuid
{
    GSSCredential *cred;

    if (uuid == nil)
        return nil;

    CFUUIDRef cfUuid = CFUUIDCreateFromString(kCFAllocatorDefault, (__bridge CFStringRef)[uuid UUIDString]);
    if (cfUuid == NULL)
        return nil;

    cred = (__bridge GSSCredential *)GSSCreateCredentialFromUUID(cfUuid);

    CFRelease(cfUuid);

#if !__has_feature(objc_arc)
    [cred autorelease];
#endif

    return cred;
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
    return GSSCredentialWithName(name, desiredMech, attributes, error);
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
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSError *error = nil;
    
    if ([urlCred hasPassword])
        [attributes setObject:[urlCred password] forKey:GSSICPassword];
    else if ([urlCred identity])
        [attributes setObject:(__bridge id)[urlCred identity] forKey:GSSICCertificate];

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
                   ^(gss_iter_OID mechOid, gss_cred_id_t mechCred) {
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

- (NSUUID *)UUID
{
    CFUUIDRef uuid = GSSCredentialCopyUUID([self _gssCred]);
    NSUUID *nsUuid;

    if (uuid == NULL)
        return NULL;

    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    if (uuidString == NULL) {
        CFRelease(uuid);
        return NULL;
    }

    nsUuid = [[NSUUID alloc] initWithUUIDString:(__bridge NSString *)uuidString];
#if !__has_feature(objc_arc)
    [nsUuid autorelease];
#endif

    CFRelease(uuidString);
    CFRelease(uuid);

    return nsUuid;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSUUID *uuid;
    NSData *exportCred;

    if ((uuid = [self UUID]))
        [coder encodeObject:uuid forKey:@"uuid"];
    else if ((exportCred = [self export]))
        [coder encodeObject:exportCred forKey:@"export-cred"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSData *exportCred;
    NSUUID *uuid;
    GSSCredential *cred = nil;

    exportCred = [coder decodeObjectOfClass:[NSData class] forKey:@"export-cred"];
    if (exportCred) {
        cred = [GSSCredential credentialWithExportedData:exportCred];
    } else {
        uuid = [coder decodeObjectOfClass:[NSUUID class] forKey:@"uuid"];
        if (uuid)
            cred = [GSSCredential credentialWithUUID:uuid];
    }

#if !__has_feature(objc_arc)
    [cred retain];
#endif

    return cred;
}

@end
