//
//  GSSPlaceholderCredential.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSCredential.h"

@interface GSSPlaceholderCredential : GSSCredential

@end

OM_uint32
GSSAcquireCred(GSSName *desiredName,
               GSSMechanism *desiredMech,
               NSDictionary *attributes,
               GSSCredential **pCredential,
               NSError **pError);

OM_uint32
GSSAcquireCredExtWrapper(OM_uint32 *minor,
                         GSSName *desiredName,
                         gss_const_OID credType,
                         const void *credData,
                         OM_uint32 timeReq,
                         GSSMechanism *desiredMech,
                         gss_cred_usage_t credUsage,
                         GSSCredential **pCredHandle);
