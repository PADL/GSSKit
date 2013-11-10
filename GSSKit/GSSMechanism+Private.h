//
//  GSSMechanism+Private.h
//  GSSKit
//
//  Created by Luke Howard on 10/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSMechanism (Private)
- (gss_const_OID)oid;
- (BOOL)isEqualToOID:(gss_const_OID)someOid;

+ (GSSMechanism *)mechanismWithOID:(gss_const_OID)oid;

@end
