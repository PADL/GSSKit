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
GSSChangePasswordWrapper(GSSName *desiredName,
                         GSSMechanism *desiredMech,
                         NSDictionary *attributes,
                         NSError **pError);

OM_uint32
GSSAcquireCredFunnel(GSSName *desiredName,
                     GSSMechanism *desiredMech,
                     NSDictionary *attributes,
                     GSSCredential **pCredential,
                     NSError **pError);
