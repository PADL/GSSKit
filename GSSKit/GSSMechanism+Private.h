//
//  GSSMechanism+Private.h
//  GSSKit
//
//  Created by Luke Howard on 10/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSMechanism (Private)
+ (GSSMechanism *)mechanismWithOID:(gss_const_OID)oid;

- (gss_const_OID)oid;
- (BOOL)isEqualToOID:(gss_const_OID)someOid;
@end

@interface GSSConcreteMechanism : GSSMechanism
{
    gss_const_OID _oid;
    gss_OID_desc _oidBuffer;
    NSData *_data;
}
@end


