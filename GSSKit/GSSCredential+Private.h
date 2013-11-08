//
//  GSSCredential+Private.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSCredential (Private)

- (gss_cred_id_t)_gssCred;
+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred;
- (instancetype)initWithGSSCred:(gss_cred_id_t)cred;

@end