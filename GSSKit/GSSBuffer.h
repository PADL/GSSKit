//
//  GSSBuffer.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSBuffer : NSData
+ (NSData *)dataWithGSSBufferNoCopy:(gss_buffer_t)buffer freeWhenDone:(BOOL)flag;
- (instancetype)initWithGSSBufferNoCopy:(gss_buffer_t)buffer freeWhenDone:(BOOL)flag;
- (gss_buffer_desc)_gssBuffer;
@end