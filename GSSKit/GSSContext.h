//
//  GSSContext.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

enum {
    GSS_C_ENC_BINARY,
    GSS_C_ENC_BASE64
};
typedef NSUInteger GSSEncoding;

@interface GSSContext : NSObject

@property(nonatomic, retain) dispatch_queue_t queue;
@property(nonatomic, retain) GSSMechanism *mechanism;
@property(nonatomic, assign) uint32_t requestFlags;
@property(nonatomic, retain) id targetName;
@property(nonatomic, retain) GSSCredential *credential;
@property(nonatomic, retain) GSSChannelBindings *channelBindings;
@property(nonatomic, assign) GSSEncoding encoding;

@property(nonatomic, readonly) GSSMechanism *finalMechanism;
@property(nonatomic, readonly) uint32_t finalFlags;
@property(nonatomic, readonly) GSSCredential *delegatedCredentials;
@property(nonatomic, readonly) NSError *lastError;

@property(nonatomic, readonly) GSSName *initiatorName;
@property(nonatomic, readonly) GSSName *acceptorName;

@property(nonatomic, readonly) BOOL isInitiator;

- (id)initWithRequestFlags:(uint32_t)flags queue:(dispatch_queue_t)queue isInitiator:(BOOL)initiator;

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(NSData *, NSError *))handler;

- (NSData *)wrapData:(NSData *)data encrypt:(uint32_t)confState;
- (NSData *)wrapData:(NSData *)data encrypt:(uint32_t)confState qopState:(uint32_t)qopState;

- (NSData *)unwrapData:(NSData *)data didEncrypt:(uint32_t *)confState;
- (NSData *)unwrapData:(NSData *)data didEncrypt:(uint32_t *)confState qopState:(uint32_t *)qopState;

- (NSData *)messageIntegrityCodeFromData:(NSData *)data;
- (NSData *)messageIntegrityCodeFromData:(NSData *)data qopState:(uint32_t)qopState;

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic;
- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic qopState:(uint32_t *)qopState;

- (BOOL)isContextEstablished;
- (BOOL)isContextExpired;

- (BOOL)isContinueNeeded;
- (BOOL)didError;

@end
