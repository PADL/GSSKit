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
                            mechanism:(gss_const_OID)desiredMech
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
         mechanism:(gss_const_OID)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSCredential");
    return nil;
}

@end