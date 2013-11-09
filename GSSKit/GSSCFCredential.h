//
//  GSSCFCredential.h
//  GSSKit
//
//  Created by Luke Howard on 9/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <GSSKit/GSSKit.h>

@interface GSSCFCredential : GSSCredential

@end

OM_uint32
GSSAcquireCredExtWrapper(OM_uint32 *minor,
                         GSSName *desiredName,
                         gss_const_OID credType,
                         const void *credData,
                         OM_uint32 timeReq,
                         GSSMechanism *desiredMech,
                         gss_cred_usage_t credUsage,
                         GSSCredential **pCredHandle);

OM_uint32
GSSChangePasswordWrapper(GSSName *desiredName,
                         GSSMechanism *desiredMech,
                         NSDictionary *attributes,
                         NSError **pError);
