//
//  GSSContext.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSContext
{
    GSSMechanism *_mechanism;
    OM_uint32 _requestFlags;
    GSSName *_targetName;
    GSSCredential *_credential;
    GSSChannelBindings *_channelBindings;
    GSSEncoding _encoding;
    
    GSSMechanism *_finalMechanism;
    OM_uint32 _finalFlags;
    time_t _expiryTime;
    GSSCredential *_delegatedCredentials;

    gss_ctx_id_t _ctx;
    dispatch_queue_t _queue;
    BOOL _isInitiator;
    OM_uint32 _major, _minor;
}

@synthesize mechanism;
@synthesize requestFlags;
@synthesize targetName;
@synthesize credential;
@synthesize channelBindings;
@synthesize encoding;

@synthesize finalMechanism;
@synthesize finalFlags;
@synthesize delegatedCredentials;

- (oneway void)dealloc
{
    gss_delete_sec_context(&_minor, &_ctx, GSS_C_NO_BUFFER);
}

- (NSError *)lastError
{
    if (GSS_ERROR(_major))
        return [NSError GSSError:_major :_minor];
    
    return nil;
}

- (BOOL)isContextEstablished
{
    return (_major == GSS_S_COMPLETE);
}

- (BOOL)isContextExpired
{
    return time(NULL) >= _expiryTime;
}

- (GSSName *)initiatorName
{
    OM_uint32 major, minor;
    gss_name_t initiatorName = GSS_C_NO_NAME;
    
    major = gss_inquire_context(&minor, _ctx, &initiatorName,
                                NULL, NULL, NULL, NULL, NULL, NULL);
    if (GSS_ERROR(major))
        return nil;
    
    return [GSSName nameWithGSSName:initiatorName freeWhenDone:YES];
}

- (GSSName *)acceptorName
{
    OM_uint32 major, minor;
    gss_name_t acceptorName = GSS_C_NO_NAME;
    
    major = gss_inquire_context(&minor, _ctx, NULL,
                                &acceptorName, NULL, NULL, NULL, NULL, NULL);
    if (GSS_ERROR(major))
        return nil;
    
    return [GSSName nameWithGSSName:acceptorName freeWhenDone:YES];
}

- (instancetype)init
{
    return [self initWithRequestFlags:0
                                queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
                          isInitiator:YES];
}

- (instancetype)initWithRequestFlags:(OM_uint32)flags queue: (dispatch_queue_t)queue isInitiator:(BOOL)initiator
{
    if ((self = [super init]) == nil)
        return nil;
    
    _requestFlags = flags;
    _queue = queue;
    _isInitiator = initiator;
    _major = GSS_S_FAILURE;
    
    return self;
}

- (void)_initSecContext:(NSData *)reqData :(NSData **)retData
{
    gss_const_OID mechType = GSS_SPNEGO_MECHANISM;
    gss_buffer_desc inputToken = GSS_C_EMPTY_BUFFER;
    struct gss_channel_bindings_struct channelBindingsStruct;
    gss_OID actualMechType = GSS_C_NO_OID;
    gss_buffer_desc outputToken = GSS_C_EMPTY_BUFFER;
    OM_uint32 timeRec = 0;
    
    *retData = nil;
    
    if (reqData)
        inputToken = [reqData _gssBuffer];
    if (self.mechanism)
        mechType = [self.mechanism oid];
    if (self.channelBindings)
        channelBindingsStruct = [self.channelBindings _gssChannelBindings];

    _major = gss_init_sec_context(&_minor,
                                  [self.credential _gssCred],
                                  &_ctx,
                                  [self.targetName _gssName],
                                  (gss_OID)mechType,
                                  self.requestFlags,
                                  GSS_C_INDEFINITE,
                                  self.channelBindings ? &channelBindingsStruct : GSS_C_NO_CHANNEL_BINDINGS,
                                  reqData ? &inputToken : GSS_C_NO_BUFFER,
                                  &actualMechType,
                                  &outputToken,
                                  &_finalFlags,
                                  &timeRec);

    if (actualMechType != GSS_C_NO_OID)
        _finalMechanism = [GSSMechanism mechanismWithOID:actualMechType];
    if (outputToken.value != NULL)
        *retData = [GSSBuffer dataWithGSSBufferNoCopy:&outputToken freeWhenDone:YES];
    if (timeRec)
        _expiryTime = time(NULL) + timeRec;
}

- (void)_acceptSecContext:(NSData *)reqData :(NSData **)retData
{
    gss_buffer_desc inputToken = [reqData _gssBuffer];
    struct gss_channel_bindings_struct channelBindingsStruct;
    gss_name_t sourceName = GSS_C_NO_NAME;
    gss_OID actualMechType = GSS_C_NO_OID;
    gss_buffer_desc outputToken = GSS_C_EMPTY_BUFFER;
    OM_uint32 timeRec = 0, tmp;
    gss_cred_id_t delegCred = GSS_C_NO_CREDENTIAL;
    
    *retData = nil;

    if (reqData)
        inputToken = [reqData _gssBuffer];
    if (self.channelBindings)
        channelBindingsStruct = [self.channelBindings _gssChannelBindings];
    
    _major = gss_accept_sec_context(&_minor,
                                    &_ctx,
                                    [self.credential _gssCred],
                                    reqData ? &inputToken : GSS_C_NO_BUFFER,
                                    self.channelBindings ? &channelBindingsStruct : GSS_C_NO_CHANNEL_BINDINGS,
                                    &sourceName,
                                    &actualMechType,
                                    &outputToken,
                                    &_finalFlags,
                                    &timeRec,
                                    &delegCred);

    if (actualMechType != GSS_C_NO_OID)
        _finalMechanism = [GSSMechanism mechanismWithOID:actualMechType];
    if (outputToken.value != NULL)
        *retData = [GSSBuffer dataWithGSSBufferNoCopy:&outputToken freeWhenDone:YES];
    if (timeRec)
        _expiryTime = time(NULL) + timeRec;
    if (delegCred)
        _delegatedCredentials = [GSSCredential credentialWithGSSCred:delegCred freeWhenDone:YES];
    
    gss_release_name(&tmp, &sourceName);
}

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(OM_uint32, OM_uint32, NSData *))handler
{
    dispatch_async(_queue, ^{
        NSData *retData = nil;
        
        if (_isInitiator)
            [self _initSecContext:reqData :&retData];
        else
            [self _acceptSecContext:reqData :&retData];
        
        handler(_major, _minor, retData);
    });
}

- (NSData *)wrapData:(NSData *)data encrypt:(BOOL)confState qopState:(gss_qop_t)qopState;
{
    gss_buffer_desc inputMessageBuffer = [data _gssBuffer];
    int actualConfState;
    gss_buffer_desc outputMessageBuffer = GSS_C_EMPTY_BUFFER;
    
    _major = gss_wrap(&_minor,
                      _ctx,
                      confState,
                      qopState,
                      &inputMessageBuffer,
                      &actualConfState,
                      &outputMessageBuffer);
    if (GSS_ERROR(_major) || actualConfState != confState)
        return nil;

    return [GSSBuffer dataWithGSSBufferNoCopy:&outputMessageBuffer freeWhenDone:YES];
}

- (NSData *)wrapData:(NSData *)data encrypt:(BOOL)confState
{
    return [self wrapData:data encrypt:confState qopState:GSS_C_QOP_DEFAULT];
}

- (NSData *)unwrapData:(NSData *)data didEncrypt:(BOOL *)didEncrypt qopState:(gss_qop_t *)qopState;
{
    gss_buffer_desc inputMessageBuffer = [data _gssBuffer];
    gss_buffer_desc outputMessageBuffer = GSS_C_EMPTY_BUFFER;
    int confState;
    
    _major = gss_unwrap(&_minor,
                        _ctx,
                        &inputMessageBuffer,
                        &outputMessageBuffer,
                        &confState,
                        qopState);
    if (GSS_ERROR(_major))
        return nil;
    
    *didEncrypt = !!confState;
    
    return [GSSBuffer dataWithGSSBufferNoCopy:&outputMessageBuffer freeWhenDone:YES];
}

- (NSData *)unwrapData:(NSData *)data didEncrypt:(BOOL *)confState
{
    gss_qop_t qopState;
    
    return [self unwrapData:data didEncrypt:confState qopState:&qopState];
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data qopState:(gss_qop_t)qopState
{
    gss_buffer_desc messageBuffer = [data _gssBuffer];
    gss_buffer_desc messageToken = GSS_C_EMPTY_BUFFER;

    _major = gss_get_mic(&_minor,
                         _ctx,
                         qopState,
                         &messageBuffer,
                         &messageToken);

    if (GSS_ERROR(_major))
        return nil;
    
    return [GSSBuffer dataWithGSSBufferNoCopy:&messageToken freeWhenDone:YES];
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data
{
    return [self messageIntegrityCodeFromData:data qopState:GSS_C_QOP_DEFAULT];
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic qopState:(gss_qop_t *)qopState
{
    gss_buffer_desc messageBuffer = [data _gssBuffer];
    gss_buffer_desc messageToken = [mic _gssBuffer];
    
    _major = gss_verify_mic(&_minor,
                            _ctx,
                            &messageBuffer,
                            &messageToken,
                            qopState);
    if (GSS_ERROR(_major))
        return NO;

    
    return YES;
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic
{
    gss_qop_t qopState;
    
    return [self verifyMessageIntegrityCodeFromData:data withCode:mic qopState:&qopState];
}

@end