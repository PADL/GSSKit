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
{
    return [[self alloc] initWithGSSCred:cred];
}

- (instancetype)initWithGSSCred:(gss_cred_id_t)cred
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