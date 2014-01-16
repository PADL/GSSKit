//
//  GSSMechanism.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

__attribute__((visibility("default")))
@interface GSSMechanism : NSObject

+ (GSSMechanism *)defaultMechanism;
+ (GSSMechanism *)SPNEGOMechanism;
+ (GSSMechanism *)kerberosMechanism;
+ (GSSMechanism *)PKU2UMechanism;
+ (GSSMechanism *)NTLMMechanism;
+ (GSSMechanism *)IAKerbMechanism;

+ (GSSMechanism *)personaMechanism;
+ (GSSMechanism *)EAPMechanism;

+ (GSSMechanism *)mechanismWithDERData:(NSData *)data;
+ (GSSMechanism *)mechanismWithSASLName:(NSString *)name;

+ (GSSMechanism *)mechanismWithOIDString:(NSString *)oidString;
+ (GSSMechanism *)mechanismWithClass:(NSString *)className;

- (NSString *)name;
- (NSString *)SASLName;
- (NSString *)oidString;
- (NSString *)mechanismClass;

- (BOOL)isSPNEGOMechanism;
- (BOOL)isKerberosMechanism;

- (BOOL)isEqual:(id)anObject;

@end
