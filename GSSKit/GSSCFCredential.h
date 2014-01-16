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

BOOL
GSSChangePasswordWrapper(GSSName *desiredName,
                         GSSMechanism *desiredMech,
                         NSDictionary *attributes,
                         NSError * __autoreleasing *pError);

GSSCredential *
GSSAcquireCredFunnel(GSSName *desiredName,
                     GSSMechanism *desiredMech,
                     NSDictionary *attributes,
                     NSError *__autoreleasing *pError);
