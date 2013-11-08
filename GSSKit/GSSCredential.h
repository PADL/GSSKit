//
//  GSSCredential.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSCredential : NSObject

// primitive methods

- (void)destroy;

// category methods

+ (GSSCredential *)credentialWithName:(GSSName *)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
                                error:(NSError **)error;

+ (GSSCredential *)credentialWithName:(GSSName *)name
                            mechanism:(GSSMechanism *)desiredMech
                           usageFlags:(OM_uint32)flags
                             password:(NSString *)password
                                error:(NSError **)error;

+ (GSSCredential *)credentialWithExportedData: (NSData *)exportedData;

+ (GSSCredential *)credentialWithURLCredential:(NSURLCredential *)urlCred
                                     mechanism:(GSSMechanism *)mech;

- (GSSName *)name;
- (OM_uint32)lifetime;
- (OM_uint32)credUsage;
- (NSArray *)mechanisms;
- (NSData *)export;

- (void)iterateWithFlags:(OM_uint32)flags ofMechanism:(GSSMechanism *)mech
                callback:(void (^)(GSSMechanism *, GSSCredential *))fun;

@end
