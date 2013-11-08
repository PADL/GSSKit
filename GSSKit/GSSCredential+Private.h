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
+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred freeWhenDone:(BOOL)flag;
- (instancetype)initWithGSSCred:(gss_cred_id_t)cred freeWhenDone:(BOOL)flag;

@end



OM_uint32
GSSAcquireCred(GSSName *desiredName,
               GSSMechanism *desiredMech,
               NSDictionary *attributes,
               GSSCredential **pCredential,
               NSError **pError);