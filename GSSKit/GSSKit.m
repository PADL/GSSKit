//
//  GSSKit.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

CFStringRef __GSSKitIdentity = CFSTR("GSSKit@gss.padl.com");
dispatch_queue_t __GSSKitBackgroundQueue = NULL;

GSSKIT_EXPORT NSString * const GSSICPassword = (__bridge NSString *)kGSSICPassword;
GSSKIT_EXPORT NSString * const GSSICCertificate = (__bridge NSString *)kGSSICCertificate;
GSSKIT_EXPORT NSString * const GSSICVerifyCredential = (__bridge NSString *)kGSSICVerifyCredential;

// workaround whilst we have to use set_cred_option
GSSKIT_EXPORT NSString * const GSSCredentialName = @"kGSSCredentialName";
GSSKIT_EXPORT NSString * const GSSCredentialMechanismOID = @"kGSSCredentialMechanismOID";

GSSKIT_EXPORT NSString * const GSSCredentialUsage = (__bridge NSString *)kGSSCredentialUsage;
GSSKIT_EXPORT NSString * const GSSCredentialUsageInitiate = (__bridge NSString *)kGSS_C_INITIATE;
GSSKIT_EXPORT NSString * const GSSCredentialUsageAccept = (__bridge NSString *)kGSS_C_ACCEPT;
GSSKIT_EXPORT NSString * const GSSCredentialUsageBoth = (__bridge NSString *)kGSS_C_BOTH;

GSSKIT_EXPORT NSString * const GSSICLKDCHostname = (__bridge NSString *)kGSSICLKDCHostname;
GSSKIT_EXPORT NSString * const GSSICKerberosCacheName = (__bridge NSString *)kGSSICKerberosCacheName;
GSSKIT_EXPORT NSString * const GSSICAppIdentifierACL = (__bridge NSString *)kGSSICAppIdentifierACL;

GSSKIT_EXPORT NSString * const GSSChangePasswordOldPassword = (__bridge NSString *)kGSSChangePasswordOldPassword;
GSSKIT_EXPORT NSString * const GSSChangePasswordNewPassword = (__bridge NSString *)kGSSChangePasswordNewPassword;

NSDictionary *GSSURLSchemeToServiceNameMap = NULL;

__attribute__((constructor))
static void
__GSSKitInit(void)
{
    __GSSKitBackgroundQueue = dispatch_queue_create("com.padl.gss.BackgroundQueue", DISPATCH_QUEUE_CONCURRENT);
    NSCAssert(__GSSKitBackgroundQueue != NULL, @"Failed to initialize __GSSKitBackgroundQueue");

    GSSURLSchemeToServiceNameMap =  @{
        @"telnet" : @"host",
        @"https": @"http",
        @"ldaps": @"ldap"
    };
}