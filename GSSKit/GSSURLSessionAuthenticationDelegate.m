//
//  GSSURLSessionAuthenticationDelegate.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSURLSessionAuthenticationTaskDelegate
{
    GSSContext *_context;
}

- (instancetype)initWithCredential:(GSSCredential *)credential
{
    if ((self = [super init]) == nil)
        return nil;
    
    _context = [[GSSContext alloc] initWithRequestFlags:GSS_C_MUTUAL_FLAG
                                                  queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                                            isInitiator:TRUE];

    _context.mechanism = [GSSMechanism SPNEGOMechanism];
    _context.credential = credential;
    _context.encoding = GSS_C_ENC_BASE64;
    
    return self;
}

- (instancetype)init
{
    return [self initWithCredential:nil];
}

- (NSData *)_gssTokenFromURLSession:(NSURLSession *)session
                               task:(NSURLSessionTask *)task
{
#if 0
    NSString *challenge = [[task response] valueForHTTPHeaderField:@"WWW-Authenticate"];
    NSArray *challengeComps = [challenge componentsSeparatedByString:@" "];
    
    if (challengeComps.count != 2)
        return nil;
    
    if (![challengeComps[0] isEqualToString:@"Negotiate"])
        return nil;
    
    return [challengeComps[1] dataUsingEncoding:NSUTF8StringEncoding];
#else
    return nil;
#endif
}

- (void)_gssTokenToURLSession:(NSURLSession *)session
                         task:(NSURLSessionTask *)task
                        token:(NSData *)token
{
//    NSString *response = [NSString stringWithFormat:@"Negotiate %@",
//                          [[NSString alloc] initWithData:token encoding:NSUTF8StringEncoding]];
    
//    [[task currentRequest] setValue:response forHTTPHeaderField:@"Authenticate"];
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
{
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSData *inputToken = [self _gssTokenFromURLSession:session task:task];
    
    if (![[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodNegotiate]) {
        completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        return;
    }

    if ([_context isContinueNeeded] && ![inputToken length]) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    if (_context.credential == nil)
        _context.credential = [GSSCredential credentialWithURLCredential:[challenge proposedCredential]
                                                               mechanism:[GSSMechanism SPNEGOMechanism]];
    if (_context.targetName == nil)
        _context.targetName = [NSString stringWithFormat:@"http@%@", [protectionSpace host]];
    
    if ([[protectionSpace protocol] isEqualToString:NSURLProtectionSpaceHTTPS] ||
        [[protectionSpace protocol] isEqualToString:NSURLProtectionSpaceHTTPProxy])
        ;    // TODO channel bindings

    [_context stepWithData:inputToken
         completionHandler:^(NSData *outputToken, NSError *error) {
             NSURLCredential *cred = [challenge proposedCredential];
             
             if (GSS_ERROR(error.code)) {
                 [self _gssTokenToURLSession:session task:task token:outputToken];
                 completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
             } else {
                 completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
             }
    }];
}

@end
