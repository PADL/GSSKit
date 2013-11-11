//
//  GSSCredential+Private.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSCredential+Private.h"

@implementation GSSCredential (Private)

+ (GSSCredential *)credentialWithGSSCred:(gss_cred_id_t)cred
                            freeWhenDone:(BOOL)flag
{
    return [GSSCFCredential credentialWithGSSCred:cred freeWhenDone:flag];
}

- (gss_cred_id_t)_gssCred
{
    NSRequestConcreteImplementation(self, _cmd, [GSSCredential class]);
    return GSS_C_NO_CREDENTIAL;
}

@end

