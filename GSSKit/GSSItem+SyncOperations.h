//
//  GSSItem+SyncOperations.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL. All rights reserved.
//

#import "GSSPlaceholderItem.h"

@interface GSSItem (SyncOperations)

- (id)_performOperationSynchronously:(const NSObject *)op
                         withOptions:(NSDictionary *)options
                               error:(NSError **)error;

- (id)acquire:(NSDictionary *)options error:(NSError **)error;
- (void)renewCredential:(NSDictionary *)options error:(NSError **)error;
- (id)getGSSCredential:(NSDictionary *)options error:(NSError **)error;
- (NSNumber *)destroyTransient:(NSDictionary *)options error:(NSError **)error;
- (NSNumber *)removeBackingCredential:(NSDictionary *)options error:(NSError **)error;
- (void)changePassword:(NSDictionary *)options error:(NSError **)error;
- (void)setDefault:(NSDictionary *)options error:(NSError **)error;
- (NSArray *)credentialDiagnostics:(NSDictionary *)options error:(NSError **)error;

@end