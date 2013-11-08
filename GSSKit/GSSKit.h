//
//  GSSKit.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GSS/gssapi.h>
#import <GSS/gssapi_apple.h>

#import <GSSKit/GSSItem.h>
#import <GSSKit/GSSItem+AsyncOperations.h>
#import <GSSKit/GSSItem+SyncOperations.h>

#import <GSSKit/GSSMechanism.h>
#import <GSSKit/GSSName.h>
#import <GSSKit/GSSCredential.h>

extern gss_OID_desc __gss_c_cred_cfdictionary_oid_desc;
#define GSS_C_CRED_CFDictionary (&__gss_c_cred_cfdictionary_oid_desc)