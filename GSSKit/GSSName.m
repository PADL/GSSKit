//
//  GSSName.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

static GSSName *placeholderName;

@implementation GSSName

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (placeholderName == nil)
            placeholderName = [super allocWithZone:zone];
    }
    
    return placeholderName;
}

+ (GSSName *)nameWithData:(NSData *)data
                 nameType:(gss_const_OID)nameType
                    error:(NSError **)error
{
    return [[self alloc] initWithData:data nameType:nameType error:error];
}

+ (GSSName *)nameWithGSSName:(gss_name_t)name freeWhenDone:(BOOL)flag
{
    return [[self alloc] initWithGSSName:name freeWhenDone:flag];
}

- (id)init
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

- (instancetype)initWithData:(NSData *)data
                    nameType:(gss_const_OID)nameType
                       error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

- (instancetype)initWithGSSName:(gss_name_t)name
                   freeWhenDone:(BOOL)flag
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

+ (GSSName *)nameWithHostBasedService:(NSString *)service withHostName:(NSString *)hostname
{
    NSString *name;
    NSError *error;
    
    name = [NSString stringWithFormat:@"%@@%@", service, hostname];
    
    return [self nameWithData:[name dataUsingEncoding:NSUTF8StringEncoding]
                     nameType:GSS_C_NT_HOSTBASED_SERVICE error:&error];
}

+ (GSSName *)nameWithUserName:(NSString *)username
{
    NSError *error;
    
    return [self nameWithData:[username dataUsingEncoding:NSUTF8StringEncoding]
                     nameType:GSS_C_NT_USER_NAME error:&error];
}

- (NSData *)exportName
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

- (NSString *)description
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

- (gss_name_t)_gssName
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

@end
