//
//  GSSItem+AsyncOperations.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSItem.h"

@interface GSSItem (AsyncOperations)

- (BOOL)acquire:(NSDictionary *)options
          queue:(dispatch_queue_t)queue
completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)renewCredential:(NSDictionary *)options
                  queue:(dispatch_queue_t)queue
      completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)getGSSCredential:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)destroyTransient:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)removeBackingCredential:(NSDictionary *)options
                          queue:(dispatch_queue_t)queue
              completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)changePassword:(NSDictionary *)options
                 queue:(dispatch_queue_t)queue
     completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)setDefault:(NSDictionary *)options
             queue:(dispatch_queue_t)queue
 completionHandler:(void (^)(NSObject *, NSError *))fun;

- (BOOL)credentialDiagnostics:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(NSObject *, NSError *))fun;

@end
