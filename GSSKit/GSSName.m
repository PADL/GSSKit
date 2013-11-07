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

- (id)init
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

- (id)initWithData:(NSData *)data
          nameType:(gss_const_OID)nameType
             error:(NSError **)error
{
    NSAssert(NO, @"Must implement a complete subclass of GSSName");
    return nil;
}

@end
