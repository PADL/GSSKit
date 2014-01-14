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
    return [self stringWithGSSBuffer:buffer freeWhenDone:NO];
}

+ (NSString *)stringWithGSSBuffer:(gss_buffer_t)buffer freeWhenDone:(BOOL)flag
{
    NSData *data = [GSSBuffer dataWithGSSBufferNoCopy:buffer freeWhenDone:flag];
    NSString *string = [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
#if !__has_feature(objc_arc)
    [string autorelease];
#endif
    
    return string;
}

- (gss_buffer_desc)_gssBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    buffer.value = (void *)[self UTF8String];
    
    return buffer;
}
@end
