//
//  NSString+GSSBufferHelper.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation NSString (GSSBufferHelper)
+ (NSString *)stringWithGSSBuffer:(gss_buffer_t)buffer
{
    NSData *data = [GSSBuffer dataWithGSSBufferNoCopy:buffer freeWhenDone:NO];
    
    return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (gss_buffer_desc)_gssBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    buffer.value = (void *)[self UTF8String];
    
    return buffer;
}
@end
