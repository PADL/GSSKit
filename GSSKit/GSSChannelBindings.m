//
//  GSSChannelBindings.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSChannelBindings
{
    OM_uint32 _initiatorAddressType;
    NSData *_initiatorAddress;
    OM_uint32 _acceptorAddressType;
    NSData *_acceptorAddress;
    NSData *_applicationData;
}

@synthesize initiatorAddressType;
@synthesize initiatorAddress;
@synthesize acceptorAddressType;
@synthesize acceptorAddress;
@synthesize applicationData;

- (struct gss_channel_bindings_struct)_gssChannelBindings
{
    struct gss_channel_bindings_struct cb;
    
    cb.initiator_addrtype = self.initiatorAddressType;
    cb.initiator_address = [self.initiatorAddress _gssBuffer];
    cb.acceptor_addrtype = self.acceptorAddressType;
    cb.acceptor_address = [self.acceptorAddress _gssBuffer];
    cb.application_data = [self.applicationData _gssBuffer];
        
    return cb;
}

@end
