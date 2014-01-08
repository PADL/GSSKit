//
//  GSSKit.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GSSKit/GSSItem.h>
#import <GSSKit/GSSItem+AsyncOperations.h>
#import <GSSKit/GSSItem+SyncOperations.h>

#import <GSSKit/GSSMechanism.h>
#import <GSSKit/GSSName.h>
#import <GSSKit/GSSCredential.h>
#import <GSSKit/GSSChannelBindings.h>
#import <GSSKit/GSSContext.h>
#import <GSSKit/GSSURLSessionAuthenticationDelegate.h>

#ifndef GSSKIT_EXPORT
#define GSSKIT_EXPORT extern
#endif

GSSKIT_EXPORT NSString * const GSSICPassword;
GSSKIT_EXPORT NSString * const GSSICCertificate;
GSSKIT_EXPORT NSString * const GSSICVerifyCredential;

GSSKIT_EXPORT NSString * const GSSCredentialUsage;
GSSKIT_EXPORT NSString * const GSSCredentialUsageInitiate;
GSSKIT_EXPORT NSString * const GSSCredentialUsageAccept;
GSSKIT_EXPORT NSString * const GSSCredentialUsageBoth;

GSSKIT_EXPORT NSString * const GSSICLKDCHostname;
GSSKIT_EXPORT NSString * const GSSICKerberosCacheName;
GSSKIT_EXPORT NSString * const GSSICAppIdentifierACL;

GSSKIT_EXPORT NSString * const GSSChangePasswordOldPassword;
GSSKIT_EXPORT NSString * const GSSChangePasswordNewPassword;

GSSKIT_EXPORT NSString * const GSSMajorErrorCodeKey;
GSSKIT_EXPORT NSString * const GSSMinorErrorCodeKey;

#if 0
GSSKIT_EXPORT NSString * const GSSMajorErrorDescriptionKey;
GSSKIT_EXPORT NSString * const GSSMinorErrorDescriptionKey;
#endif

GSSKIT_EXPORT NSString * const GSSMechanismOIDKey;
GSSKIT_EXPORT NSString * const GSSMechanismKey;
