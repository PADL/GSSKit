//
//  GSSKit.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import <GSS/gssapi.h>
//#import <GSS/gssapi_apple.h>

#import <GSSKit/GSSItem.h>
#import <GSSKit/GSSItem+AsyncOperations.h>
#import <GSSKit/GSSItem+SyncOperations.h>

#import <GSSKit/GSSMechanism.h>
#import <GSSKit/GSSName.h>
#import <GSSKit/GSSCredential.h>
#import <GSSKit/GSSChannelBindings.h>
#import <GSSKit/GSSContext.h>
#import <GSSKit/GSSURLSessionAuthenticationDelegate.h>

//extern gss_OID_desc __gss_c_cred_cfdictionary_oid_desc;
//#define GSS_C_CRED_CFDictionary (&__gss_c_cred_cfdictionary_oid_desc)

extern NSString * const GSSMajorStatusErrorKey;
extern NSString * const GSSMinorStatusErrorKey;


extern NSString * const GSSICPassword;
extern NSString * const GSSICCertificate;
extern NSString * const GSSICVerifyCredential;

extern NSString * const GSSCredentialUsage;
extern NSString * const GSSCredentialUsageInitiate;
extern NSString * const GSSCredentialUsageAccept;
extern NSString * const GSSCredentialUsageBoth;

extern NSString * const GSSICLKDCHostname;
extern NSString * const GSSICKerberosCacheName;
extern NSString * const GSSICAppIdentifierACL;

extern NSString * const GSSChangePasswordOldPassword;
extern NSString * const GSSChangePasswordNewPassword;