//
//  GSSItem+AsyncOperations.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSItem (AsyncOperations)

- (BOOL)acquire:(NSDictionary *)options
          queue:(dispatch_queue_t)queue
completionHandler:(void (^)(GSSCredential *, NSError *))fun
{
    return [self _performOperation:kGSSOperationAcquire
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)renewCredential:(NSDictionary *)options
                  queue:(dispatch_queue_t)queue
      completionHandler:(void (^)(id, NSError *))fun
{
    return [self _performOperation:kGSSOperationRenewCredential
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)getGSSCredential:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(GSSCredential *, NSError *))fun
{
    return [self _performOperation:kGSSOperationGetGSSCredential
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)destroyTransient:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(NSNumber *, NSError *))fun
{
    return [self _performOperation:kGSSOperationDestoryTransient
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)removeBackingCredential:(NSDictionary *)options
                          queue:(dispatch_queue_t)queue
              completionHandler:(void (^)(id, NSError *))fun
{
    return [self _performOperation:kGSSOperationRemoveBackingCredential
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)changePassword:(NSDictionary *)options
                 queue:(dispatch_queue_t)queue
     completionHandler:(void (^)(id, NSError *))fun
{
    return [self _performOperation:kGSSOperationChangePassword
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)setDefault:(NSDictionary *)options
             queue:(dispatch_queue_t)queue
 completionHandler:(void (^)(id, NSError *))fun
{
    return [self _performOperation:kGSSOperationSetDefault
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)credentialDiagnostics:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(NSArray *, NSError *))fun
{
    return [self _performOperation:kGSSOperationCredentialDiagnostics
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

@end

