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
completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationAcquire
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)renewCredential:(NSDictionary *)options
                  queue:(dispatch_queue_t)queue
      completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationRenewCredential
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)getGSSCredential:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationGetGSSCredential
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)destroyTransient:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationDestoryTransient
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)removeBackingCredential:(NSDictionary *)options
                          queue:(dispatch_queue_t)queue
              completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationRemoveBackingCredential
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)changePassword:(NSDictionary *)options
                 queue:(dispatch_queue_t)queue
     completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationChangePassword
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)setDefault:(NSDictionary *)options
             queue:(dispatch_queue_t)queue
 completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationSetDefault
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

- (BOOL)credentialDiagnostics:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(NSObject *, NSError *))fun
{
    return [self _performOperation:(__bridge const NSObject *)kGSSOperationCredentialDiagnostics
                       withOptions:options
                             queue:queue
                 completionHandler:fun];
}

@end

