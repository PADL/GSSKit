//
//  GSSItem+AsyncOperations.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@class GSSCredential;

@interface GSSItem (AsyncOperations)

- (BOOL)acquire:(NSDictionary *)options
          queue:(dispatch_queue_t)queue
completionHandler:(void (^)(GSSCredential *, NSError *))fun;

- (BOOL)renewCredential:(NSDictionary *)options
                  queue:(dispatch_queue_t)queue
      completionHandler:(void (^)(id, NSError *))fun;

- (BOOL)getGSSCredential:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(GSSCredential *, NSError *))fun;

- (BOOL)destroyTransient:(NSDictionary *)options
                   queue:(dispatch_queue_t)queue
       completionHandler:(void (^)(NSNumber *, NSError *))fun;

- (BOOL)removeBackingCredential:(NSDictionary *)options
                          queue:(dispatch_queue_t)queue
              completionHandler:(void (^)(id, NSError *))fun;

- (BOOL)changePassword:(NSDictionary *)options
                 queue:(dispatch_queue_t)queue
     completionHandler:(void (^)(id, NSError *))fun;

- (BOOL)setDefault:(NSDictionary *)options
             queue:(dispatch_queue_t)queue
 completionHandler:(void (^)(id, NSError *))fun;

- (BOOL)credentialDiagnostics:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(NSArray *, NSError *))fun;

@end
