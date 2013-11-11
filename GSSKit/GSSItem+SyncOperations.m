//
//  GSSItem+SyncOperations.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSItem (SyncOperations)

- (GSSCredential *)acquire:(NSDictionary *)options error:(NSError **)error
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

- (GSSCredential *)getGSSCredential:(NSDictionary *)options error:(NSError **)error
{
    return [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationGetGSSCredential
                                    withOptions:options
                                          error:error];
}

- (BOOL)destroyTransient:(NSDictionary *)options error:(NSError **)error
{
    id ret;
    
    ret = [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationDestoryTransient
                                   withOptions:options
                                         error:error];
    
    return [ret booleanValue];
}

- (BOOL)removeBackingCredential:(NSDictionary *)options error:(NSError **)error
{
    id ret;
    
    ret = [self _performOperationSynchronously:(__bridge const NSObject *)kGSSOperationRemoveBackingCredential
                                   withOptions:options
                                         error:error];

    return [ret booleanValue];
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
