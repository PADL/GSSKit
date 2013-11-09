//
//  GSSMechanism.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <GSS/gssapi.h>

@interface GSSMechanism : NSObject
+ (GSSMechanism *)defaultMechanism;
+ (GSSMechanism *)SPNEGOMechanism;
+ (GSSMechanism *)kerberosMechanism;
+ (GSSMechanism *)PKU2UMechanism;
+ (GSSMechanism *)NTLMMechanism;

+ (GSSMechanism *)personaMechanism;
+ (GSSMechanism *)EAPMechanism;

+ (GSSMechanism *)mechanismWithOID:(gss_const_OID)oid;
+ (GSSMechanism *)mechanismWithDERData:(NSData *)data;
+ (GSSMechanism *)mechanismWithSASLName:(NSString *)name;

- (gss_const_OID)oid;
- (NSString *)oidString;

- (NSString *)name;
- (NSString *)SASLName;

- (BOOL)isSPNEGOMechanism;
- (BOOL)isKerberosMechanism;

- (BOOL)isEqual:(id)anObject;
- (BOOL)isEqualToOID:(gss_const_OID)someOid;

@end
