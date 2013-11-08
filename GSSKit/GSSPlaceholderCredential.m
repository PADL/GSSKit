//
//  GSSPlaceholderCredential.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

// ARC disabled

@implementation GSSPlaceholderCredential

#pragma mark Initialization

- (id)initWithName:(GSSName *)name
         mechanism:(GSSMechanism *)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError **)error
{
    OM_uint32 major;
    gss_cred_id_t cred;
    
    [self release];
    
    *error = nil;
    
    major = gss_aapl_initial_cred((gss_name_t)name, [desiredMech oid], (CFDictionaryRef)attributes, &cred, (CFErrorRef *)error);
    if (GSS_ERROR(major) && *error == nil)
        *error = [NSError GSSError:major];
    
    [*error autorelease];
    
    return (id)cred;
}

#pragma mark Bridging

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

- (gss_cred_id_t)_gssCred
{
    return (gss_cred_id_t)self;
}

@end
