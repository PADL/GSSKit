//
//  GSSCredential+Private.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSCredential (Private)

+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred freeWhenDone:(BOOL)flag;
- (gss_cred_id_t)_gssCred;

@end

