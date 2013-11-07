//
//  GSSItem+SyncOperations.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSItem (SyncOperations)
- (id)_performOperationSynchronously:(const NSObject *)op
                         withOptions:(NSDictionary *)options
                               error:(NSError **)error
{
    BOOL bResult;
    __block id object = nil;
    dispatch_queue_t queue = dispatch_queue_create("com.padl.GSSItemOperationQueue", NULL);
    
    *error = nil;
    
    bResult = [self _performOperation:op
                          withOptions:options
                                queue:queue
                    completionHandler:^(NSObject *o, NSError *e) {
                            object = o;
                            *error = e;
                        }];
    
    if (bResult == NO)
        return nil;
    
    return object;
}

- (id)acquire:(NSDictionary *)options error:(NSError **)error
{
    return [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationAcquire
                                    withOptions:options
                                          error:error];
}

- (void)renewCredential:(NSDictionary *)options error:(NSError **)error
{
    [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationRenewCredential
                             withOptions:options
                                   error:error];
}

- (id)getGSSCredential:(NSDictionary *)options error:(NSError **)error
{
    return [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationGetGSSCredential
                                    withOptions:options
                                          error:error];
}

- (NSNumber *)destroyTransient:(NSDictionary *)options error:(NSError **)error
{
    return [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationDestoryTransient
                                    withOptions:options
                                          error:error];
}

- (NSNumber *)removeBackingCredential:(NSDictionary *)options error:(NSError **)error
{
    return [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationRemoveBackingCredential
                                    withOptions:options
                                          error:error];
}

- (void)changePassword:(NSDictionary *)options error:(NSError **)error
{
    [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationChangePassword
                             withOptions:options
                                   error:error];
}

- (void)setDefault:(NSDictionary *)options error:(NSError **)error
{
    [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationSetDefault
                             withOptions:options
                                   error:error];
}

- (NSArray *)credentialDiagnostics:(NSDictionary *)options error:(NSError **)error
{
    return [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationCredentialDiagnostics
                                    withOptions:options
                                          error:error];
}

@end