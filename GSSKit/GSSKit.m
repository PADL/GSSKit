//
//  GSSKit.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation NSError (GSSKit)

+ (NSError *)gssError:(OM_uint32)majorStatus
                     :(OM_uint32)minorStatus
{
    return [NSError errorWithDomain:@"org.h5l.GSS" code:(NSInteger)majorStatus userInfo:nil];
}

+ (NSError *)gssError:(OM_uint32)majorStatus
{
    return [self gssError:majorStatus :0];
}

@end