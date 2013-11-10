//
//  GSSChannelBindings.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSChannelBindings : NSObject

@property(nonatomic, assign) uint32_t initiatorAddressType;
@property(nonatomic, copy) NSData *initiatorAddress;
@property(nonatomic, assign) uint32_t acceptorAddressType;
@property(nonatomic, copy) NSData *acceptorAddress;
@property(nonatomic, copy) NSData *applicationData;

@end
