//
//  NSArray+GSSOIDHelper.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation NSArray (GSSOIDHelper)

+ (NSArray *)arrayWithGSSOIDSet:(gss_OID_set)oids
{
    OM_uint32 minor;
    NSMutableArray *array;
    
    array = [NSMutableArray arrayWithCapacity:oids->count];
    
    for (OM_uint32 i = 0; i < oids->count; i++) {
        gss_OID thisOid = &oids->elements[i];
        NSData *derData = [NSData dataWithBytes:thisOid->elements length:thisOid->length];
        GSSMechanism *mech = [GSSMechanism mechanismWithDERData:derData];
        
        [array addObject:mech];
    }
    
    gss_release_oid_set(&minor, &oids);
    
    return array;
}

@end
