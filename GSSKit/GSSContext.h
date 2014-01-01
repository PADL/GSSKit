//
//  GSSContext.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

typedef NS_ENUM(NSUInteger, GSSEncoding) {
    GSSEncodingBinary,
    GSSEncodingBase64
};

typedef NS_OPTIONS(uint32_t, GSSFlags) {
    GSSDelegFlag = 1,
    GSSMutualFlag = 2,
    GSSReplayFlag = 4,
    GSSSequenceFlag = 8,
    GSSConfFlag = 16,
    GSSIntegFlag = 32,
    GSSAnonFlag = 64,
    GSSProtReadyFlag = 128,
    GSSTransFlag = 256
};

typedef NS_ENUM(uint32_t, GSSQopState) {
    GSSQopDefault = 0,
};

__attribute__((visibility("default")))
@interface GSSContext : NSObject

@property(nonatomic, retain) dispatch_queue_t queue;
@property(nonatomic, retain) GSSMechanism *mechanism;
@property(nonatomic, assign) GSSFlags requestFlags;
@property(nonatomic, retain) id targetName;
@property(nonatomic, retain) GSSCredential *credential;
@property(nonatomic, retain) GSSChannelBindings *channelBindings;
@property(nonatomic, assign) GSSEncoding encoding;

@property(nonatomic, readonly) GSSMechanism *finalMechanism;
@property(nonatomic, readonly) GSSFlags finalFlags;
@property(nonatomic, readonly) GSSCredential *delegatedCredentials;
@property(nonatomic, readonly) NSError *lastError;

@property(nonatomic, readonly) GSSName *initiatorName;
@property(nonatomic, readonly) GSSName *acceptorName;

@property(nonatomic, readonly) BOOL isInitiator;

- (id)initWithRequestFlags:(GSSFlags)flags queue:(dispatch_queue_t)queue isInitiator:(BOOL)initiator;

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(NSData *, NSError *))handler;

- (NSData *)wrapData:(NSData *)data encrypt:(GSSFlags)confState;
- (NSData *)wrapData:(NSData *)data encrypt:(GSSFlags)confState qopState:(GSSQopState)qopState;

- (NSData *)unwrapData:(NSData *)data didEncrypt:(GSSFlags *)confState;
- (NSData *)unwrapData:(NSData *)data didEncrypt:(GSSFlags *)confState qopState:(GSSQopState *)qopState;

- (NSData *)messageIntegrityCodeFromData:(NSData *)data;
- (NSData *)messageIntegrityCodeFromData:(NSData *)data qopState:(GSSQopState)qopState;

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic;
- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic qopState:(GSSQopState *)qopState;

- (BOOL)isContextEstablished;
- (BOOL)isContextExpired;

- (BOOL)isContinueNeeded;
- (BOOL)didError;

@end
