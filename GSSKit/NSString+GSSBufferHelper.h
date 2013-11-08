//
//  NSString+GSSBufferHelper.h
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@class NSString;

#import <GSS/gssapi.h>

@interface NSString (GSSBufferHelper)
+ (NSString *)stringWithGSSBuffer:(gss_buffer_t)buffer;
- (gss_buffer_desc)_gssBuffer;
@end
