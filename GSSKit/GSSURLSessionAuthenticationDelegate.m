//
//  GSSURLSessionAuthenticationDelegate.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

/*
 
 @property(nonatomic, retain) GSSMechanism *mechanism;
 @property(nonatomic, assign) OM_uint32 requestFlags;
 @property(nonatomic, retain) GSSName *targetName;
 @property(nonatomic, retain) GSSCredential *credential;
 @property(nonatomic, retain) GSSChannelBindings *channelBindings;
 @property(nonatomic, assign) GSSEncoding encoding;
 
 @property(nonatomic, readonly) GSSMechanism *finalMechanism;
 @property(nonatomic, readonly) OM_uint32 finalFlags;
 @property(nonatomic, readonly) GSSCredential *delegatedCredentials;
 @property(nonatomic, readonly) NSError *lastError;
 
 @property(nonatomic, readonly) GSSName *initiatorName;
 @property(nonatomic, readonly) GSSName *acceptorName;
 
 - (void)stepWithData:(NSData *)reqData
 completionHandler:(void (^)(NSData *, NSError *))handler;
*/


@implementation GSSURLSessionAuthenticationDelegate
{
    GSSContext *_context;
}

- (instancetype)initWithCredentials:(GSSCredential *)credential
{
    if ((self = [super init]) == nil)
        return nil;
    
    _context = [[GSSContext alloc] initWithRequestFlags:GSS_C_MUTUAL_FLAG
                                                  queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                                            isInitiator:TRUE];

    _context.mechanism = [GSSMechanism mechanismSPNEGO];
    _context.credential = credential;
    _context.encoding = GSS_C_ENC_BASE64;
    
    return self;
}

- (instancetype)init
{
    return [self initWithCredentials:nil];
}


- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSData *inputToken = nil;
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    
    if (![[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodNegotiate]) {
        completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        return;
    }

    [_context stepWithData:inputToken completionHandler:^(NSData *outputToken, NSError *error) {
        NSURLCredential *cred;

        if ([error code] == GSS_S_COMPLETE || [error _gssContinueNeeded]) {
            completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }];
}

@end
