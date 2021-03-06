//
//  GSSItem.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

__attribute__((visibility("default")))
@interface GSSItem : NSObject <NSSecureCoding, NSCopying>

+ (GSSItem *)add:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error;
+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError * __autoreleasing *)error;
+ (BOOL)delete:(NSDictionary *)query error:(NSError * __autoreleasing *)error;
+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError * __autoreleasing *)error;

- (BOOL)delete:(NSError * __autoreleasing *)error;
- (id)valueForKey:(NSString *)key;

@end

