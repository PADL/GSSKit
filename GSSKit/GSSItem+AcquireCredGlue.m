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

- (GSSName *)_itemGSSName
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
        return [GSSName nameWithExportedData:name];
    
    return nil;
}

- (GSSMechanism *)_itemGSSMech
{
    NSString *mechClass = (__bridge NSString *)GSSItemGetValue((__bridge GSSItemRef)self, kGSSAttrClass);

    return [GSSMechanism mechanismWithClass:mechClass];
}

- (const NSString *)_credKeyForItemKey:(NSString *)key
{
    if ([key isEqualToString:(__bridge NSString *)kGSSAttrCredentialPassword])
        return GSSICPassword;
    else if ([key isEqualToString:(__bridge NSString *)kGSSAttrCredentialSecIdentity])
        return GSSICCertificate;
    else if ([key hasPrefix:@"kGSSAttrCredential"])
        return [key stringByReplacingOccurrencesOfString:@"kGSSAttrCredential" withString:@"kGSSIC"];
    
    return nil;
}

- (void)_itemAcquireOperation:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(GSSCredential *cred, NSError *))fun
{
    GSSName *name = [self _itemGSSName];
    GSSMechanism *mech = [self _itemGSSMech];
    GSSCredential *cred = nil;
    NSError *error = nil;
    NSMutableDictionary *gssAttrs = [NSMutableDictionary dictionary];
    
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        const NSString *mappedKey = [self _credKeyForItemKey:key];
        
        if (mappedKey)
            [gssAttrs setObject:obj forKey:mappedKey];
    }];
    
    [gssAttrs setObject:GSSCredentialUsageInitiate forKey:GSSCredentialUsage];
    
    cred = GSSAcquireCredFunnel(name, mech, gssAttrs, &error);
    GSSItemGetValue((__bridge GSSItemRef)self, kGSSAttrCredentialExists);
    
    dispatch_async(queue, ^{
        fun(cred, error);
#if !__has_feature(objc_arc)
        [cred release];
#endif
    });
}

@end
