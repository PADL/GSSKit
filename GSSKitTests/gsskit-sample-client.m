#include <GSSKit/GSSKit.h>

static void step(GSSContext *ctx, dispatch_semaphore_t sema)
{
    NSData *initiatorToken = nil;

    [ctx stepWithData:initiatorToken
        completionHandler:^(NSData *outputToken, NSError *error) {
            NSLog(@"step - got token %@ error %@", outputToken, error);
            dispatch_semaphore_signal(sema);
    }];
}

int main(int argc, char *argv[])
{
    dispatch_queue_t queue;
    GSSCredential *cred = nil;
    GSSContext *ctx = nil;
    NSDictionary *attrs = @{
                            (__bridge NSString *)kGSSCredentialUsage : (__bridge NSString *)kGSS_C_INITIATE
                            };
    NSError *err = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    queue = dispatch_queue_create("com.padl.gsskit-sample-client.worker-queue", NULL);
 
    cred = [GSSCredential credentialWithName:@"lukeh@DE.PADL.COM"
                                   mechanism:[GSSMechanism mechanismKerberos]
                                  attributes:attrs
                                       error:&err];
    if (!cred) {
        NSLog(@"failed to acquire cred - %@", [err description]);
        exit([err code]);
    }

    ctx = [[GSSContext alloc] initWithRequestFlags:0
                                             queue:queue
                                       isInitiator:YES];
    
    ctx.targetName = @"host@win-vqv9ffpvu3b.de.padl.com";
    ctx.credential = cred;
    
    step(ctx, sema);
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    exit([[ctx lastError] code]);
}