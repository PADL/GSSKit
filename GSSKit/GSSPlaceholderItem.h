//
//  GSSItem.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSSItem : NSObject

+ (BOOL)update:(NSDictionary *)query withAttributes:(NSDictionary *)attributes error:(NSError **)error;
+ (BOOL)delete:(NSDictionary *)query error:(NSError **)error;
+ (NSArray *)copyMatching:(NSDictionary *)query error:(NSError **)error;
+ (GSSItem *)itemWithAttributes:(NSDictionary *)attributes error:(NSError **)error;

- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)error;
- (BOOL)delete:(NSError **)error;
- (id)valueForKey:(NSString *)key;

@end
