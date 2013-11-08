//
//  GSSMechanism.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <GSS/gssapi.h>

@interface GSSMechanism : NSObject
+ (GSSMechanism *)mechanismSPNEGO;
+ (GSSMechanism *)mechanismKerberos;

#if 0
+ (GSSMechanism *)mechanismPKU2U;
+ (GSSMechanism *)mechanismSCRAM;
+ (GSSMechanism *)mechanismNTLM;
+ (GSSMechanism *)mechanismSASLDigestMD5;
#endif

+ (GSSMechanism *)mechanismWithOID:(gss_OID)oid;
+ (GSSMechanism *)mechanismWithDERData:(NSData *)data;
+ (GSSMechanism *)mechanismWithSASLName:(NSString *)name;

- (gss_const_OID)oid;
- (NSString *)name;
- (NSString *)SASLName;

@end
