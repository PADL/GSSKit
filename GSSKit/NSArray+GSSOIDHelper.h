//
//  NSArray+GSSOIDHelper.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@class NSArray;

#import <GSS/gssapi.h>

@interface NSArray (GSSOIDHelper)
+ (NSArray *)arrayWithGSSOIDSet:(gss_OID_set)oids;
@end
