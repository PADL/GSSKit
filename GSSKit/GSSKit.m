//
//  GSSKit.m
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation NSError (GSSKit)

+ (NSError *)gssError:(OM_uint32)majorStatus
                     :(OM_uint32)minorStatus
{
    return [NSError errorWithDomain:@"org.h5l.GSS" code:(NSInteger)majorStatus userInfo:nil];
}

+ (NSError *)gssError:(OM_uint32)majorStatus
{
    return [self gssError:majorStatus :0];
}

@end

@implementation NSString (GSSKit)
+ (NSString *)stringWithGSSBuffer:(gss_buffer_t)buffer
{
    NSData *data = [NSData dataWithGSSBuffer:buffer];
    
    return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (gss_buffer_desc)GSSBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    buffer.value = (void *)[self UTF8String];
    
    return buffer;
}
@end

@implementation NSData (GSSKit)
+ (NSData *)dataWithGSSBuffer:(gss_buffer_t)buffer
{
    return [NSData dataWithBytes:buffer->value length:buffer->length];
}

- (gss_buffer_desc)GSSBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self length];
    buffer.value = (void *)[self bytes];
    
    return buffer;
}
@end