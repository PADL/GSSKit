//
//  GSSChannelBindings.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

__attribute__((visibility("default")))
@interface GSSChannelBindings : NSObject <NSSecureCoding, NSCopying>
{
    uint32_t _initiatorAddressType;
    NSData *_initiatorAddress;
    uint32_t _acceptorAddressType;
    NSData *_acceptorAddress;
    NSData *_applicationData;
}

@property(nonatomic, assign) uint32_t initiatorAddressType;
@property(nonatomic, copy) NSData *initiatorAddress;
@property(nonatomic, assign) uint32_t acceptorAddressType;
@property(nonatomic, copy) NSData *acceptorAddress;
@property(nonatomic, copy) NSData *applicationData;

@end
