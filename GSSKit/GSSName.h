//
//  GSSName.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSName : NSObject
+ (GSSName *)nameWithData:(NSData *)data
                 nameType:(gss_const_OID)nameType
                    error:(NSError **)error;

+ (GSSName *)nameWithGSSName:(gss_name_t)name freeWhenDone:(BOOL)flag;
+ (GSSName *)nameWithHostBasedService: (NSString *)service withHostName: (NSString *)hostname;
+ (GSSName *)nameWithUserName: (NSString *)username;

- (instancetype)initWithData:(NSData *)data
                    nameType:(gss_const_OID)nameType
                       error:(NSError **)error;
- (instancetype)initWithGSSName:(gss_name_t)name freeWhenDone:(BOOL)flag;

- (NSData *)exportName;
- (NSString *)description;

@end
