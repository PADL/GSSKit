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

NSString * const GSSICPassword = (__bridge NSString *)kGSSICPassword;
NSString * const GSSICCertificate = (__bridge NSString *)kGSSICCertificate;
NSString * const GSSICVerifyCredential = (__bridge NSString *)kGSSICVerifyCredential;

NSString * const GSSCredentialUsage = (__bridge NSString *)kGSSCredentialUsage;
NSString * const GSSCredentialUsageInitiate = (__bridge NSString *)kGSS_C_INITIATE;
NSString * const GSSCredentialUsageAccept = (__bridge NSString *)kGSS_C_ACCEPT;
NSString * const GSSCredentialUsageBoth = (__bridge NSString *)kGSS_C_BOTH;

NSString * const GSSICLKDCHostname = (__bridge NSString *)kGSSICLKDCHostname;
NSString * const GSSICKerberosCacheName = (__bridge NSString *)kGSSICKerberosCacheName;
NSString * const GSSICAppIdentifierACL = (__bridge NSString *)kGSSICAppIdentifierACL;

NSString * const GSSChangePasswordOldPassword = (__bridge NSString *)kGSSChangePasswordOldPassword;
NSString * const GSSChangePasswordNewPassword = (__bridge NSString *)kGSSChangePasswordNewPassword;

__attribute__((constructor))
static void
__GSSKitInit(void)
{
    __GSSKitBackgroundQueue = dispatch_queue_create("com.padl.gss.BackgroundQueue", DISPATCH_QUEUE_CONCURRENT);
    NSCAssert(__GSSKitBackgroundQueue != NULL, @"Failed to initialize __GSSKitBackgroundQueue");
}
