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
    NSMutableArray *array;
    
    array = [NSMutableArray arrayWithCapacity:oids->count];
    
    for (OM_uint32 i = 0; i < oids->count; i++) {
        gss_OID thisOid = &oids->elements[i];

        if (thisOid->elements == NULL) {
            NSLog(@"+[NSArray(GSSOIDHelper) arrayWithGSSOIDSet:]: NULL OID in %p", thisOid);
            continue;
        } else if (thisOid->length == 0) {
            NSLog(@"+[NSArray(GSSOIDHelper) arrayWithGSSOIDSet:]: zero length OID in %p", thisOid);
            continue;
        }

        NSData *derData = [NSData dataWithBytes:thisOid->elements length:thisOid->length];
        GSSMechanism *mech = [GSSMechanism mechanismWithDERData:derData];

        if (mech != nil)
            [array addObject:mech];
        else
            NSLog(@"+[NSArray(GSSOIDHelper) arrayWithGSSOIDSet:]: could not parse mechanism");
    }
    
    return array;
}

@end
