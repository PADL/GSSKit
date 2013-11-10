//
//  GSSName+Private.h
//  GSSKit
//
//  Created by Luke Howard on 10/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import <GSSKit/GSSKit.h>

@interface GSSName (Private)
+ (GSSName *)nameWithData:(NSData *)data
                 nameType:(gss_const_OID)nameType
                    error:(NSError **)error;
+ (GSSName *)nameWithGSSName:(gss_name_t)name freeWhenDone:(BOOL)flag;
- (gss_name_t)_gssName;
@end
