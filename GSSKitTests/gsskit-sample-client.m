#include <GSSKit/GSSKit.h>

int main(int argc, char *argv[])
{
    dispatch_queue_t queue;
    GSSCredential *initiatorCred = nil;
    GSSContext *initiatorCtx = nil, *acceptorCtx = nil;
    NSDictionary *attrs = @{
                            (__bridge NSString *)kGSSCredentialUsage : (__bridge NSString *)kGSS_C_INITIATE
                            };
    NSError *err = nil;
    __block NSData *initiatorToken = nil, *acceptorToken = nil;
    
    queue = dispatch_queue_create("com.padl.gsskit-sample-client.worker-queue", NULL);
 
    initiatorCred = [GSSCredential credentialWithName:@"lukeh@DE.PADL.COM"
                                            mechanism:[GSSMechanism kerberosMechanism]
                                           attributes:attrs
                                                error:&err];
    if (!initiatorCred) {
        NSLog(@"failed to acquire cred - %@", [err description]);
        exit([err code]);
    }

    initiatorCtx = [[GSSContext alloc] initWithRequestFlags:0 //GSS_C_MUTUAL_FLAG
                                                      queue:queue
                                                isInitiator:YES];
    
    initiatorCtx.targetName = @"host@win-vqv9ffpvu3b.de.padl.com";
    initiatorCtx.credential = initiatorCred;
    
    acceptorCtx = [[GSSContext alloc] initWithRequestFlags:0
                                                     queue:queue
                                               isInitiator:NO];
    
    acceptorCtx.credential = [GSSCredential credentialWithName:@"host@rand.mit.de.padl.com"
                                                     mechanism:[GSSMechanism kerberosMechanism]
                                                    attributes:@{(__bridge NSString *)kGSSCredentialUsage : (__bridge NSString *)kGSS_C_ACCEPT}
                                                         error:&err];
    
    do {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        [initiatorCtx stepWithData:acceptorToken
                 completionHandler:^(NSData *outputToken, NSError *error) {
                     initiatorToken = outputToken;
                     dispatch_semaphore_signal(sema);
                 }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        if (GSS_ERROR([[initiatorCtx lastError] code]) || ![initiatorToken length])
            break;
        
        NSLog(@"Sending initiator token %@", initiatorToken);
        
        [acceptorCtx stepWithData:initiatorToken
                completionHandler:^(NSData *outputToken, NSError *error) {
                    acceptorToken = outputToken;
                    dispatch_semaphore_signal(sema);
                }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        if (GSS_ERROR([[acceptorCtx lastError] code]))
            break;
        
        NSLog(@"Sending acceptor token %@", acceptorToken);
    } while ([[initiatorCtx lastError] code] == GSS_S_CONTINUE_NEEDED);

    NSLog(@"Initiator status %ld acceptor status %ld", [[initiatorCtx lastError] code], [[acceptorCtx lastError] code]);
    
    exit([[initiatorCtx lastError] code]);
}