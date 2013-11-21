//
//  GSSItem+SyncOperations.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSItem (SyncOperations)

- (GSSCredential *)acquire:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    return [self _performOperationSynchronously:kGSSOperationAcquire
                                    withOptions:options
                                          error:error];
}

- (void)renewCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    [self _performOperationSynchronously:kGSSOperationRenewCredential
                             withOptions:options
                                   error:error];
}

- (GSSCredential *)getGSSCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    return [self _performOperationSynchronously:kGSSOperationGetGSSCredential
                                    withOptions:options
                                          error:error];
}

- (BOOL)destroyTransient:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    id ret;
    
    ret = [self _performOperationSynchronously:kGSSOperationDestoryTransient
                                   withOptions:options
                                         error:error];
    
    return [ret booleanValue];
}

- (BOOL)removeBackingCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    id ret;
    
    ret = [self _performOperationSynchronously:kGSSOperationRemoveBackingCredential
                                   withOptions:options
                                         error:error];

    return [ret booleanValue];
}

- (void)changePassword:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    [self _performOperationSynchronously:kGSSOperationChangePassword
                             withOptions:options
                                   error:error];
}

- (void)setDefault:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    [self _performOperationSynchronously:kGSSOperationSetDefault
                             withOptions:options
                                   error:error];
}

- (NSArray *)credentialDiagnostics:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    return [self _performOperationSynchronously:kGSSOperationCredentialDiagnostics
                                    withOptions:options
                                          error:error];
}

@end
