//
//  GSSItem+AcquireCredGlue.m
//  GSSKit
//
//  Created by Luke Howard on 11/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

/*
 * Semi-replacement for itemAcquire() in GSS.framework. We need this to support
 * extensible mappings of GSSItem to gss_acquire_cred_ext() dictionaries, which
 * will be used by CredUI. This can go away eventually if anything gets
 * integrated into OS X.
 */
@implementation GSSItem (AcquireCredGlue)

- (GSSName *)_itemGssName
{
    id type = (__bridge id)GSSItemGetValue((__bridge GSSItemRef)self, kGSSAttrNameType);
    id name = (__bridge id)GSSItemGetValue((__bridge GSSItemRef)self, kGSSAttrName);
    
    if (type == nil || name == nil)
        return nil;
    
    if ([type isEqual:(__bridge id)kGSSAttrNameTypeGSSUsername])
        return [GSSName nameWithUserName:name];
    else if ([type isEqual:(__bridge id)kGSSAttrNameTypeGSSHostBasedService])
        return [GSSName nameWithHostBasedService:name];
    else if ([type isEqual:(__bridge id)kGSSAttrNameTypeGSSExportedName])
        return [GSSName nameWithExportedName:name];
    
    return nil;
}

- (GSSMechanism *)_itemGssMech
{
    id type = (__bridge id)GSSItemGetValue((__bridge GSSItemRef)self, kGSSAttrClass);
    GSSMechanism *mech;
    
    if ([type isEqual:(__bridge id)kGSSAttrClassKerberos])
        mech = [GSSMechanism kerberosMechanism];
    else if ([type isEqual:(__bridge id)kGSSAttrClassNTLM])
        mech = [GSSMechanism NTLMMechanism];
    else if ([type isEqual:(__bridge id)kGSSAttrClassIAKerb])
        mech = [GSSMechanism IAKerbMechanism];
    else
        mech = [GSSMechanism defaultMechanism];
    
    return mech;
}

- (const NSString *)_credKeyForItemKey:(NSString *)key
{
    if ([key isEqualToString:(__bridge NSString *)kGSSAttrCredentialPassword])
        return GSSICPassword;
    else if ([key isEqualToString:(__bridge NSString *)kGSSAttrCredentialSecIdentity])
        return GSSICCertificate;
    else
        return [key stringByReplacingOccurrencesOfString:@"kGSSAttrCredential" withString:@"kGSSIC"];
    
    return nil;
}

- (void)_itemAcquireOperation:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(GSSCredential *cred, NSError *))fun
{
    GSSName *name = [self _itemGssName];
    GSSMechanism *mech = [self _itemGssMech];
    GSSCredential *cred = nil;
    NSError *error = nil;
    NSMutableDictionary *gssAttrs = [NSMutableDictionary dictionary];
    
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        const NSString *mappedKey = [self _credKeyForItemKey:key];
        
        if (mappedKey)
            gssAttrs[mappedKey] = obj;
    }];
    
    GSSAcquireCredFunnel(name, mech, gssAttrs, &cred, &error);
    GSSItemGetValue((__bridge GSSItemRef)self, kGSSAttrCredentialExists);
    
    dispatch_async(queue, ^{
        fun(cred, error);
    });
}

@end
