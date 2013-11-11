//
//  GSSMechanism.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSMechanism : NSObject
+ (GSSMechanism *)defaultMechanism;
+ (GSSMechanism *)SPNEGOMechanism;
+ (GSSMechanism *)kerberosMechanism;
+ (GSSMechanism *)PKU2UMechanism;
+ (GSSMechanism *)NTLMMechanism;

+ (GSSMechanism *)personaMechanism;
+ (GSSMechanism *)EAPMechanism;

+ (GSSMechanism *)mechanismWithDERData:(NSData *)data;
+ (GSSMechanism *)mechanismWithSASLName:(NSString *)name;

- (NSString *)name;
- (NSString *)SASLName;
- (NSString *)oidString;

- (BOOL)isSPNEGOMechanism;
- (BOOL)isKerberosMechanism;

- (BOOL)isEqual:(id)anObject;
@end
