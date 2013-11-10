//
//  GSSItem+SyncOperations.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSItem (SyncOperations)

/*
 * Credentials are identfied by:
 *
 *  kGSSAttrClass           kGSSAttrClassKerberos/kGSSAttrClassNTLM/kGSSAttrClassIAKerb
 *  kGSSAttrNameType        kGSSAttrNameTypeGSSUsername/kGSSAttrNameTypeGSSHostBasedService/kGSSAttrNameTypeGSSExportedName
 *  kGSSAttrName            CFStringRef/CFDataRef
 *  kGSSAttrUUID            CFStringRef
 *
 *
 */

/*
 * Acquire credentials, either using the kGSSAttrCredentialPassword in the
 * options dictionary, or by looking in the keychain for a generic credential
 * identified by UUID.
 */
- (id)acquire:(NSDictionary *)options error:(NSError **)error;

/*
 * Renew credential.
 */
- (void)renewCredential:(NSDictionary *)options error:(NSError **)error;
- (id)getGSSCredential:(NSDictionary *)options error:(NSError **)error;
- (NSNumber *)destroyTransient:(NSDictionary *)options error:(NSError **)error;
- (NSNumber *)removeBackingCredential:(NSDictionary *)options error:(NSError **)error;
- (void)changePassword:(NSDictionary *)options error:(NSError **)error;
- (void)setDefault:(NSDictionary *)options error:(NSError **)error;
- (NSArray *)credentialDiagnostics:(NSDictionary *)options error:(NSError **)error;

@end