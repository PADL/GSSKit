//
//  GSSItem+SyncOperations.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@class GSSCredential;

@interface GSSItem (SyncOperations)

/*
 * Credentials are identfied by:
 *
 *  kGSSAttrClass           kGSSAttrClassKerberos/kGSSAttrClassNTLM/kGSSAttrClassIAKerb
 *  kGSSAttrNameType        kGSSAttrNameTypeGSSUsername/kGSSAttrNameTypeGSSHostBasedService/kGSSAttrNameTypeGSSExportedName
 *  kGSSAttrName            CFStringRef/CFDataRef
 *  kGSSAttrUUID            CFStringRef
 *  kGSSAttrCredentialPassword  -> kGSSICPassword
 *  kGSSAttrCredentialSecIdentity -> kGSSICCertificate
 *
 * On output:
 *
 *  kGSSAttrNameDisplay     CFStringRef 
 *  kGSSAttrCredentialExists    CFBoolean
 *
 */

/*
 * Acquire credentials, either using the kGSSAttrCredentialPassword in the
 * options dictionary, or by looking in the keychain for a generic credential
 * identified by UUID.
 */
- (GSSCredential *)acquire:(NSDictionary *)options error:(NSError * __autoreleasing *)error;

/*
 * Renew credential.
 */
- (BOOL)renewCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error;
- (GSSCredential *)getGSSCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error;
- (BOOL)destroyTransient:(NSDictionary *)options error:(NSError * __autoreleasing *)error;
- (BOOL)removeBackingCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error;
- (BOOL)changePassword:(NSDictionary *)options error:(NSError * __autoreleasing *)error;
- (BOOL)setDefault:(NSDictionary *)options error:(NSError * __autoreleasing *)error;
- (NSArray *)credentialDiagnostics:(NSDictionary *)options error:(NSError * __autoreleasing *)error;

@end
