//
//  GSSKit.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSSItem : NSObject

+ (GSSItem *)itemWithAttributes:(NSDictionary *)attributes error:(NSError **)error;
+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError **)error;
+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError **)error;
+ (BOOL)delete:(NSDictionary *)query error:(NSError **)error;
+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError **)error;

- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)error;
- (BOOL)delete:(NSError **)error;
- (BOOL)_performOperation:(const NSObject *)op
              withOptions:(NSDictionary *)options
                    queue:(dispatch_queue_t)queue
        completionHandler:(void (^)(NSObject *, NSError *))fun;
- (id)valueForKey:(NSString *)key;

@end