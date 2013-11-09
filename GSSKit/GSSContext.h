//
//  GSSContext.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#include <GSS/gssapi.h>

enum {
    GSS_C_ENC_BINARY,
    GSS_C_ENC_BASE64
};
typedef OM_uint32 GSSEncoding;

@interface GSSContext : NSObject

@property(nonatomic, retain) dispatch_queue_t queue;
@property(nonatomic, retain) GSSMechanism *mechanism;
@property(nonatomic, assign) OM_uint32 requestFlags;
@property(nonatomic, retain) id targetName;
@property(nonatomic, retain) GSSCredential *credential;
@property(nonatomic, retain) GSSChannelBindings *channelBindings;
@property(nonatomic, assign) GSSEncoding encoding;

@property(nonatomic, readonly) GSSMechanism *finalMechanism;
@property(nonatomic, readonly) OM_uint32 finalFlags;
@property(nonatomic, readonly) GSSCredential *delegatedCredentials;
@property(nonatomic, readonly) NSError *lastError;

@property(nonatomic, readonly) GSSName *initiatorName;
@property(nonatomic, readonly) GSSName *acceptorName;

- (id)initWithRequestFlags:(OM_uint32)flags queue:(dispatch_queue_t)queue isInitiator:(BOOL)initiator;

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(NSData *, NSError *))handler;

- (NSData *)wrapData:(NSData *)data encrypt:(OM_uint32)confState;
- (NSData *)wrapData:(NSData *)data encrypt:(OM_uint32)confState qopState:(gss_qop_t)qopState;

- (NSData *)unwrapData:(NSData *)data didEncrypt:(OM_uint32 *)confState;
- (NSData *)unwrapData:(NSData *)data didEncrypt:(OM_uint32 *)confState qopState:(gss_qop_t *)qopState;

- (NSData *)messageIntegrityCodeFromData:(NSData *)data;
- (NSData *)messageIntegrityCodeFromData:(NSData *)data qopState:(gss_qop_t)qopState;

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic;
- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic qopState:(gss_qop_t *)qopState;

- (BOOL)isContextEstablished;
- (BOOL)isContextExpired;

@end