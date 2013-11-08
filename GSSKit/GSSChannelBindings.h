//
//  GSSChannelBindings.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSChannelBindings : NSObject

@property(nonatomic, assign) OM_uint32 initiatorAddressType;
@property(nonatomic, copy) NSData *initiatorAddress;
@property(nonatomic, assign) OM_uint32 acceptorAddressType;
@property(nonatomic, copy) NSData *acceptorAddress;
@property(nonatomic, copy) NSData *applicationData;

- (struct gss_channel_bindings_struct)_gssChannelBindings;

@end