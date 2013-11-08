//
//  GSSURLSessionAuthenticationDelegate.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@class GSSCredential;

@interface GSSURLSessionAuthenticationTaskDelegate : NSObject

- (instancetype)initWithCredential:(GSSCredential *)credential;

@end
