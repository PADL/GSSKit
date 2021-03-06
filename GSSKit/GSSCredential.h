//
//  GSSCredential.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

__attribute__((visibility("default")))
@interface GSSCredential : NSObject <NSSecureCoding>

// primitive methods

- (void)destroy;

// category methods

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech;

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes;

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           attributes:(NSDictionary *)attributes
                                error:(NSError * __autoreleasing *)error;

+ (GSSCredential *)credentialWithName:(id)name
                            mechanism:(GSSMechanism *)desiredMech
                           usageFlags:(uint32_t)flags
                             password:(NSString *)password
                                error:(NSError * __autoreleasing *)error;

+ (GSSCredential *)credentialWithExportedData: (NSData *)exportedData;

+ (GSSCredential *)credentialWithURLCredential:(NSURLCredential *)urlCred
                                     mechanism:(GSSMechanism *)mech;

+ (GSSCredential *)credentialWithUUID:(NSUUID *)uuid;

- (id)initWithName:(id)name
         mechanism:(GSSMechanism *)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError * __autoreleasing *)error;

- (GSSName *)name;
- (uint32_t)lifetime;
- (uint32_t)credUsage;
- (NSArray *)mechanisms;
- (NSData *)export;
- (NSData *)labelForKey:(NSString *)key;
- (void)setLabel:(NSData *)label forKey:(NSString *)key;
- (NSUUID *)UUID;

- (BOOL)validate;
- (BOOL)validate:(NSError * __autoreleasing *)error;

- (void)iterateWithFlags:(uint32_t)flags ofMechanism:(GSSMechanism *)mech
                callback:(void (^)(GSSMechanism *, GSSCredential *))fun;

@end
