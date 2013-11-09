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
    OM_uint32 _major, _minor;
    id _targetName;
    gss_ctx_id_t _ctx;
    time_t _expiryTime;
}

@synthesize mechanism = _mechanism;
@synthesize requestFlags = _requestFlags;
@synthesize credential = _credential;
@synthesize channelBindings = _channelBindings;
@synthesize encoding = _encoding;
@synthesize queue = _queue;
@synthesize finalMechanism = _finalMechanism;
@synthesize finalFlags = _finalFlags;
@synthesize delegatedCredentials = _delegatedCredentials;
@synthesize isInitiator = _isInitiator;

- (id)targetName
{
    return _targetName;
}

- (void)setTargetName:(id)someName
{
    if ([someName isKindOfClass:[NSString class]])
        someName = [GSSName nameWithHostBasedService:someName];
    else if (![someName isKindOfClass:[GSSName class]])
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"-[GSSContext setTargetName:...] requires a NSString or GSSName"]
                                     userInfo:nil];

    _targetName = someName;
}

- (oneway void)dealloc
{
    gss_delete_sec_context(&_minor, &_ctx, GSS_C_NO_BUFFER);
}

- (NSError *)lastError
{
    if (_major != GSS_S_COMPLETE)
        return [NSError GSSError:_major :_minor];
    else
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
    return [self initWithRequestFlags:0 queue:nil isInitiator:YES];
}

- (instancetype)initWithRequestFlags:(OM_uint32)flags
                               queue:(dispatch_queue_t)someQueue
                         isInitiator:(BOOL)initiator
{
    if ((self = [super init]) == nil)
        return nil;
    
    if (!someQueue)
        someQueue = dispatch_queue_create("com.padl.GSSContextQueue", NULL);
    
    self.requestFlags = flags;
    self.queue = someQueue;
    _isInitiator = initiator;
    _major = GSS_S_FAILURE;
    
    return self;
}

- (NSData *)_encodeToken:(gss_buffer_t)buffer
{
    NSData *data = [GSSBuffer dataWithGSSBufferNoCopy:buffer freeWhenDone:YES];
    
    if (self.encoding == GSS_C_ENC_BASE64)
        data = [data base64EncodedDataWithOptions:0];
    
    return data;
}

- (gss_buffer_desc)_decodeToken:(NSData *)data
                         cookie:(id *)pData
{
    if (self.encoding == GSS_C_ENC_BASE64) {
        data = [[NSData alloc] initWithBase64EncodedData:data options:0];
        *pData = data;
    }

    return [data _gssBuffer];
}

- (void)_initSecContext:(NSData *)reqData
                       :(NSData **)retData
{
    gss_buffer_desc inputToken = GSS_C_EMPTY_BUFFER;
    struct gss_channel_bindings_struct channelBindingsStruct;
    gss_OID actualMechType = GSS_C_NO_OID;
    gss_buffer_desc outputToken = GSS_C_EMPTY_BUFFER;
    OM_uint32 timeRec = 0;
    id cookie = nil;
    
    *retData = nil;
    
    if (reqData)
        inputToken = [self _decodeToken:reqData cookie:&cookie];
    if (self.channelBindings)
        channelBindingsStruct = [self.channelBindings _gssChannelBindings];

    _major = gss_init_sec_context(&_minor,
                                  self.credential ? [self.credential _gssCred] : GSS_C_NO_CREDENTIAL,
                                  &_ctx,
                                  self.targetName ? [self.targetName _gssName] : GSS_C_NO_NAME,
                                  self.mechanism ? (gss_OID)[self.mechanism oid] : GSS_C_NO_OID,
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
        *retData = [self _encodeToken:&outputToken];
    if (timeRec)
        _expiryTime = time(NULL) + timeRec;
}

- (void)_acceptSecContext:(NSData *)reqData
                         :(NSData **)retData
{
    id cookie = nil;
    gss_buffer_desc inputToken = GSS_C_EMPTY_BUFFER;
    struct gss_channel_bindings_struct channelBindingsStruct;
    gss_name_t sourceName = GSS_C_NO_NAME;
    gss_OID actualMechType = GSS_C_NO_OID;
    gss_buffer_desc outputToken = GSS_C_EMPTY_BUFFER;
    OM_uint32 timeRec = 0, tmp;
    gss_cred_id_t delegCred = GSS_C_NO_CREDENTIAL;
    
    *retData = nil;

    if (reqData)
        inputToken = [self _decodeToken:reqData cookie:&cookie];
    if (self.channelBindings)
        channelBindingsStruct = [self.channelBindings _gssChannelBindings];
    
    _major = gss_accept_sec_context(&_minor,
                                    &_ctx,
                                    self.credential ? [self.credential _gssCred] : GSS_C_NO_CREDENTIAL,
                                    &inputToken,
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
        *retData = [self _encodeToken:&outputToken];
    if (timeRec)
        _expiryTime = time(NULL) + timeRec;
    if (delegCred)
        _delegatedCredentials = [GSSCredential credentialWithGSSCred:delegCred freeWhenDone:YES];
    
    gss_release_name(&tmp, &sourceName);
}

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(NSData *, NSError *))handler
{
    dispatch_async(_queue, ^{
        NSData *retData = nil;
        
        if (_isInitiator)
            [self _initSecContext:reqData :&retData];
        else
            [self _acceptSecContext:reqData :&retData];
        
        handler(retData, self.lastError);
    });
}

- (NSData *)wrapData:(NSData *)data
             encrypt:(OM_uint32)confState
            qopState:(gss_qop_t)qopState;
{
    gss_buffer_desc inputMessageBuffer = [data _gssBuffer];
    int actualConfState;
    gss_buffer_desc outputMessageBuffer = GSS_C_EMPTY_BUFFER;
    
    _major = gss_wrap(&_minor,
                      _ctx,
                      !!(confState & GSS_C_CONF_FLAG),
                      qopState,
                      &inputMessageBuffer,
                      &actualConfState,
                      &outputMessageBuffer);
    if (GSS_ERROR(_major) || actualConfState != confState)
        return nil;

    return [self _encodeToken:&outputMessageBuffer];
}

- (NSData *)wrapData:(NSData *)data
             encrypt:(OM_uint32)confState
{
    return [self wrapData:data encrypt:confState qopState:GSS_C_QOP_DEFAULT];
}

- (NSData *)unwrapData:(NSData *)data
            didEncrypt:(OM_uint32 *)didEncrypt
              qopState:(gss_qop_t *)qopState;
{
    id cookie = nil;
    gss_buffer_desc inputMessageBuffer = [self _decodeToken:data cookie:&cookie];
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
    
    *didEncrypt = confState ? GSS_C_CONF_FLAG : GSS_C_INTEG_FLAG;
    
    return [GSSBuffer dataWithGSSBufferNoCopy:&outputMessageBuffer freeWhenDone:YES];
}

- (NSData *)unwrapData:(NSData *)data
            didEncrypt:(OM_uint32 *)confState
{
    gss_qop_t qopState;
    
    return [self unwrapData:data didEncrypt:confState qopState:&qopState];
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data
                                qopState:(gss_qop_t)qopState
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
    
    return [self _encodeToken:&messageToken];
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data
{
    return [self messageIntegrityCodeFromData:data qopState:GSS_C_QOP_DEFAULT];
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data
                                  withCode:(NSData *)mic
                                  qopState:(gss_qop_t *)qopState
{
    id cookie = nil;
    gss_buffer_desc messageBuffer = [data _gssBuffer];
    gss_buffer_desc messageToken = [self _decodeToken:mic cookie:&cookie];
    
    _major = gss_verify_mic(&_minor,
                            _ctx,
                            &messageBuffer,
                            &messageToken,
                            qopState);
    if (GSS_ERROR(_major))
        return NO;
    
    return YES;
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data
                                  withCode:(NSData *)mic
{
    gss_qop_t qopState;
    
    return [self verifyMessageIntegrityCodeFromData:data withCode:mic qopState:&qopState];
}

@end
