//
//  GSSContext.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@protocol CUIContextBoxing
@property (nonatomic, assign) void *context;

- (NSData *)exportContext;
- (BOOL)importContext:(NSData *)data;

@end

@interface GSSContext () <CUIContextBoxing>
@property(nonatomic, retain) GSSMechanism *finalMechanism;
@property(nonatomic, retain) GSSCredential *delegatedCredentials;
@end

@interface GSSContext (CredUI)
/* make this read-write */
- (BOOL)_promptForCredentials:(NSError **)error;
@end

@interface GSSConcreteContext : GSSContext
{
    OM_uint32 _major, _minor;
    id _targetName;
    gss_ctx_id_t _ctx;
    time_t _expiryTime;

    GSSMechanism *_mechanism;
    GSSFlags _requestFlags;
    GSSCredential *_credential;
    GSSChannelBindings *_channelBindings;
    GSSEncoding _encoding;
    dispatch_queue_t _queue;
    GSSMechanism *_finalMechanism;
    GSSFlags _finalFlags;
    GSSCredential *_delegatedCredentials;
    BOOL _isInitiator;
    BOOL _promptForCredentials;
    id _window;
}
@end

@implementation GSSContext

@dynamic context;
@dynamic mechanism;
@dynamic requestFlags;
@dynamic targetName;
@dynamic credential;
@dynamic channelBindings;
@dynamic encoding;
@dynamic queue;

@dynamic finalMechanism;
@dynamic finalFlags;
@dynamic delegatedCredentials;
@dynamic lastError;

@dynamic initiatorName;
@dynamic acceptorName;

@dynamic isInitiator;
@dynamic promptForCredentials; // requires GSSKitUI
@dynamic window; // requires GSSKitUI

- (id)initWithRequestFlags:(GSSFlags)flags queue:(dispatch_queue_t)queue isInitiator:(BOOL)initiator
{
#if !__has_feature(objc_arc)
    [self release];
#endif
    return ((self = [[GSSConcreteContext alloc] initWithRequestFlags:flags queue:queue isInitiator:initiator]));
}

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(NSData *, NSError *))handler
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
}

- (NSData *)wrapData:(NSData *)data
             encrypt:(GSSFlags)confState
{
    return [self wrapData:data encrypt:confState qopState:GSS_C_QOP_DEFAULT];
}

- (NSData *)wrapData:(NSData *)data encrypt:(GSSFlags)confState qopState:(GSSQopState)qopState
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return nil;
}

- (NSData *)unwrapData:(NSData *)data
            didEncrypt:(GSSFlags *)confState
{
    GSSQopState qopState;
    
    return [self unwrapData:data didEncrypt:confState qopState:&qopState];
}


- (NSData *)unwrapData:(NSData *)data didEncrypt:(GSSFlags *)confState qopState:(GSSQopState *)qopState
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return nil;
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data
{
    return [self messageIntegrityCodeFromData:data qopState:GSS_C_QOP_DEFAULT];
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data qopState:(GSSQopState)qopState
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return nil;
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic
{
    GSSQopState qopState;
    
    return [self verifyMessageIntegrityCodeFromData:data withCode:mic qopState:&qopState];
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data withCode:(NSData *)mic qopState:(GSSQopState *)qopState
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return NO;
}

- (BOOL)isContextEstablished
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return NO;
}

- (BOOL)isContextExpired
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return NO;
}

- (BOOL)isContinueNeeded
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return NO;
}

- (BOOL)didError
{
    NSRequestConcreteImplementation(self, _cmd, [GSSContext class]);
    return NO;
}

- (NSData *)exportContext
{
    NSData *data;
    OM_uint32 major, minor;
    gss_buffer_desc exportedContext = GSS_C_EMPTY_BUFFER;
    gss_ctx_id_t context = self.context;

    major = gss_export_sec_context(&minor, &context, &exportedContext);
    if (GSS_ERROR(major))
        return nil;
    
    data = [NSData dataWithBytes:exportedContext.value length:exportedContext.length];
    gss_release_buffer(&minor, &exportedContext);
   
    self.context = GSS_C_NO_CONTEXT;
 
    return data;
}

- (BOOL)importContext:(NSData *)data
{
    OM_uint32 major, minor;
    gss_buffer_desc exportedContext;
    void *context = GSS_C_NO_CONTEXT;
    
    if (!data.length)
        return NO;
    
    exportedContext.length = data.length;
    exportedContext.value = (void *)data.bytes;
    
    major = gss_import_sec_context(&minor, &exportedContext, (gss_ctx_id_t *)&context);
    if (GSS_ERROR(major))
        return NO;

    self.context = context;

    return YES;
}

@end

@implementation GSSConcreteContext

@synthesize mechanism = _mechanism;
@synthesize requestFlags = _requestFlags;
@synthesize targetName = _targetName;
@synthesize credential = _credential;
@synthesize channelBindings = _channelBindings;
@synthesize encoding = _encoding;
@synthesize queue = _queue;

@synthesize finalMechanism = _finalMechanism;
@synthesize finalFlags = _finalFlags;
@synthesize delegatedCredentials = _delegatedCredentials;

@synthesize isInitiator = _isInitiator;
@synthesize promptForCredentials = _promptForCredentials;
@synthesize window = _window;

- (id)targetName
{
    return _targetName;
}

- (void)setTargetName:(id)someName
{
    if ([someName isKindOfClass:[NSString class]])
        someName = [GSSName nameWithHostBasedService:someName];
    else if ([someName isKindOfClass:[NSURL class]])
        someName = [GSSName nameWithURL:someName];
    else if (![someName isKindOfClass:[GSSName class]])
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"-[GSSContext setTargetName:...] requires a NSString, NSURL or GSSName"]
                                     userInfo:nil];

#if __has_feature(objc_arc)
    _targetName = ((GSSName *)someName);
#else
    if (someName != _targetName) {
        [_targetName release];
        _targetName = [((GSSName *)someName) retain];
    }
#endif
}

- (dispatch_queue_t)queue
{
    return _queue;
}

- (void)setQueue:(dispatch_queue_t)aQueue
{
#if __has_feature(objc_arc)
    _queue = aQueue;
#else
    if (aQueue != _queue) {
        if (_queue)
            dispatch_release(_queue);
        dispatch_retain(aQueue);
        _queue = aQueue;
    }
#endif
}

- (oneway void)dealloc
{
    gss_delete_sec_context(&_minor, &_ctx, GSS_C_NO_BUFFER);
    
#if !__has_feature(objc_arc)
    [_mechanism release];
    [_credential release];
    [_channelBindings release];
    if (_queue)
        dispatch_release(_queue);
    [_finalMechanism release];
    [_delegatedCredentials release];
    if (_queue)
        dispatch_release(_queue);
    if (_window)
        [_window release];

    [super dealloc];
#endif
}

- (NSError *)lastError
{
    if (_major != GSS_S_COMPLETE)
        return [NSError GSSError:_major :_minor :(self.finalMechanism ? self.finalMechanism : self.mechanism)];
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

- (BOOL)isContinueNeeded;
{
    return _major == GSS_S_CONTINUE_NEEDED;
}

- (BOOL)didError
{
    return GSS_ERROR(_major);
}

- (GSSName *)initiatorName
{
    OM_uint32 major, minor;
    gss_name_t initiatorName = GSS_C_NO_NAME;
    
    major = gss_inquire_context(&minor, self.context, &initiatorName,
                                NULL, NULL, NULL, NULL, NULL, NULL);
    if (GSS_ERROR(major))
        return nil;
    
    return [GSSName nameWithGSSName:initiatorName freeWhenDone:YES];
}

- (GSSName *)acceptorName
{
    OM_uint32 major, minor;
    gss_name_t acceptorName = GSS_C_NO_NAME;
    
    major = gss_inquire_context(&minor, self.context, NULL,
                                &acceptorName, NULL, NULL, NULL, NULL, NULL);
    if (GSS_ERROR(major))
        return nil;
    
    return [GSSName nameWithGSSName:acceptorName freeWhenDone:YES];
}

- (instancetype)init
{
    return [self initWithRequestFlags:0 queue:nil isInitiator:YES];
}

- (instancetype)initWithRequestFlags:(GSSFlags)flags
                               queue:(dispatch_queue_t)someQueue
                         isInitiator:(BOOL)initiator
{
    static dispatch_once_t defaultQueueOnceToken;
    static dispatch_queue_t defaultQueue;

    if ((self = [super init]) == nil)
        return nil;
    
    if (someQueue == NULL) {
        dispatch_once(&defaultQueueOnceToken, ^{
            defaultQueue = dispatch_queue_create("com.padl.gss.DefaultContextQueue", DISPATCH_QUEUE_SERIAL);
        });

        someQueue = defaultQueue;
    }
    
    self.requestFlags = flags;
    self.queue = someQueue;
    
    _isInitiator = initiator;
    _major = GSS_S_FAILURE;
    
    return self;
}

- (NSData *)_encodeToken:(gss_buffer_t)buffer
{
    NSData *data = [GSSBuffer dataWithGSSBufferNoCopy:buffer freeWhenDone:YES];
    
    if (self.encoding == GSSEncodingBase64)
        data = [data base64EncodedDataWithOptions:0];
    
    return data;
}

- (gss_buffer_desc)_decodeToken:(NSData *)data
                         cookie:(id __autoreleasing *)pData
{
    if (self.encoding == GSSEncodingBase64) {
        data = [[NSData alloc] initWithBase64EncodedData:data options:0];
#if !__has_feature(objc_arc)
        [data autorelease];
#endif
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
        self.finalMechanism = [GSSMechanism mechanismWithOID:actualMechType];
    if (outputToken.value != NULL)
        *retData = [self _encodeToken:&outputToken];
    if (timeRec)
        _expiryTime = time(NULL) + timeRec;

#if 0
    if (_major == GSS_S_COMPLETE &&
        (_finalFlags & self.requestFlags) != self.requestFlags)
        ;
#endif
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
        self.finalMechanism = [GSSMechanism mechanismWithOID:actualMechType];
    if (outputToken.value != NULL)
        *retData = [self _encodeToken:&outputToken];
    if (timeRec)
        _expiryTime = time(NULL) + timeRec;
    if (delegCred)
        self.delegatedCredentials = [GSSCredential credentialWithGSSCred:delegCred freeWhenDone:YES];
    
    gss_release_name(&tmp, &sourceName);
}

- (BOOL)_maybePromptForCredentials:(NSError **)promptError
{
    if ([self.lastError _gssPromptingNeeded] &&
        self.promptForCredentials &&
        [self respondsToSelector:@selector(_promptForCredentials:)])
        return [self _promptForCredentials:promptError];
    else
        return NO;
}

- (void)stepWithData:(NSData *)reqData
   completionHandler:(void (^)(NSData *, NSError *))handler
{
    dispatch_async(__GSSKitBackgroundQueue, ^{
        NSData *retData = nil;
        NSError *promptError = nil;

        if (_isInitiator) {
        retryISC:
            promptError = nil;
            [self _initSecContext:reqData :&retData];
            if ([self _maybePromptForCredentials:&promptError])
                goto retryISC;
        } else {
            [self _acceptSecContext:reqData :&retData];
        }
        
        dispatch_async(_queue, ^{
            handler(retData, promptError ? promptError : self.lastError);
        });
    });
}

- (NSData *)wrapData:(NSData *)data
             encrypt:(GSSFlags)confState
            qopState:(GSSQopState)qopState
{
    gss_buffer_desc inputMessageBuffer = [data _gssBuffer];
    int actualConfState;
    gss_buffer_desc outputMessageBuffer = GSS_C_EMPTY_BUFFER;
    
    _major = gss_wrap(&_minor,
                      self.context,
                      !!(confState & GSS_C_CONF_FLAG),
                      qopState,
                      &inputMessageBuffer,
                      &actualConfState,
                      &outputMessageBuffer);
    if (GSS_ERROR(_major) || actualConfState != confState)
        return nil;

    return [self _encodeToken:&outputMessageBuffer];
}

- (NSData *)unwrapData:(NSData *)data
            didEncrypt:(GSSFlags *)didEncrypt
              qopState:(GSSQopState *)qopState
{
    id cookie = nil;
    gss_buffer_desc inputMessageBuffer = [self _decodeToken:data cookie:&cookie];
    gss_buffer_desc outputMessageBuffer = GSS_C_EMPTY_BUFFER;
    int confState;
    
    _major = gss_unwrap(&_minor,
                        self.context,
                        &inputMessageBuffer,
                        &outputMessageBuffer,
                        &confState,
                        qopState);
    if (GSS_ERROR(_major))
        return nil;
    
    *didEncrypt = confState ? GSS_C_CONF_FLAG : GSS_C_INTEG_FLAG;
    
    return [GSSBuffer dataWithGSSBufferNoCopy:&outputMessageBuffer freeWhenDone:YES];
}

- (NSData *)messageIntegrityCodeFromData:(NSData *)data
                                qopState:(GSSQopState)qopState
{
    gss_buffer_desc messageBuffer = [data _gssBuffer];
    gss_buffer_desc messageToken = GSS_C_EMPTY_BUFFER;

    _major = gss_get_mic(&_minor,
                         self.context,
                         qopState,
                         &messageBuffer,
                         &messageToken);

    if (GSS_ERROR(_major))
        return nil;
    
    return [self _encodeToken:&messageToken];
}

- (BOOL)verifyMessageIntegrityCodeFromData:(NSData *)data
                                  withCode:(NSData *)mic
                                  qopState:(GSSQopState *)qopState
{
    id cookie = nil;
    gss_buffer_desc messageBuffer = [data _gssBuffer];
    gss_buffer_desc messageToken = [self _decodeToken:mic cookie:&cookie];
    
    _major = gss_verify_mic(&_minor,
                            self.context,
                            &messageBuffer,
                            &messageToken,
                            qopState);
    if (GSS_ERROR(_major))
        return NO;
    
    return YES;
}

- (void)setContext:(void *)aContext
{
    if (aContext != _ctx) {
        OM_uint32 minor;
        gss_delete_sec_context(&minor, &_ctx, GSS_C_NO_BUFFER);
        _ctx = aContext;
    }
}

- (void *)context
{
    return _ctx;
}

@end
