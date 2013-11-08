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

- (id)init
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
    return nil;
}

- (id)initWithName:(GSSName *)name
         mechanism:(GSSMechanism *)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
    return nil;
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
    NSMutableArray *mechs;
    
    major = gss_inquire_cred(&minor, [self _gssCred], NULL, NULL, NULL, &oids);
    if (GSS_ERROR(major) || oids == GSS_C_NO_OID_SET)
        return nil;
    
    mechs = [NSMutableArray arrayWithCapacity:oids->count];
    
    for (OM_uint32 i = 0; i < oids->count; i++) {
        gss_OID thisOid = &oids->elements[i];
        NSData *derData = [NSData dataWithBytes:thisOid->elements length:thisOid->length];
        GSSMechanism *mech = [GSSMechanism mechanismWithDERData:derData];
        
        [mechs addObject:mech];
    
    }
    
    return mechs;
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

- (gss_cred_id_t)_gssCred
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
    return GSS_C_NO_CREDENTIAL;
}

@end
