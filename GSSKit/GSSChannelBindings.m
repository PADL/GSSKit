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
    uint32_t _initiatorAdressType;
    NSData *_initiatorAddress;
    uint32_t _acceptorAddressType;
    NSData *_acceptorAddress;
    NSData *_applicationData;
}

@synthesize initiatorAddressType = _initiatorAddressType;
@synthesize initiatorAddress = _initiatorAddress;
@synthesize acceptorAddressType = _acceptorAddressType;
@synthesize acceptorAddress = _acceptorAddress;
@synthesize applicationData = _applicationData;

@end
