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
    id cred;
    
    [self _performOperationSynchronously:kGSSOperationAcquire
                             withOptions:options
                                  object:&cred
                                   error:error];
    
    return cred;
}

- (BOOL)renewCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    return [self _performOperationSynchronously:kGSSOperationRenewCredential
                                    withOptions:options
                                         object:NULL
                                          error:error];
}

- (GSSCredential *)getGSSCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    id cred;
    
    [self _performOperationSynchronously:kGSSOperationGetGSSCredential
                             withOptions:options
                                  object:&cred
                                   error:error];
    
    return cred;
}

- (BOOL)destroyTransient:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    id ret;
    
    [self _performOperationSynchronously:kGSSOperationDestoryTransient
                             withOptions:options
                                  object:&ret
                                   error:error];
    
    return [ret booleanValue];
}

- (BOOL)removeBackingCredential:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    id ret;
    
    [self _performOperationSynchronously:kGSSOperationRemoveBackingCredential
                            withOptions:options
                                 object:&ret
                                  error:error];

    return [ret booleanValue];
}

- (BOOL)changePassword:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    return [self _performOperationSynchronously:kGSSOperationChangePassword
                                    withOptions:options
                                         object:NULL
                                          error:error];
}

- (BOOL)setDefault:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    return [self _performOperationSynchronously:kGSSOperationSetDefault
                                    withOptions:options
                                         object:NULL
                                          error:error];
}

- (NSArray *)credentialDiagnostics:(NSDictionary *)options error:(NSError * __autoreleasing *)error
{
    id diags;
    
    [self _performOperationSynchronously:kGSSOperationCredentialDiagnostics
                             withOptions:options
                                  object:&diags
                                   error:error];
    
    return diags;
}

@end
