//
//  GSSBuffer.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSBuffer

- (void)dealloc
{
    OM_uint32 minor;
    
    if (_freeIt)
        gss_release_buffer(&minor, &_data);
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

+ (NSData *)dataWithGSSBufferNoCopy:(gss_buffer_t)buffer freeWhenDone:(BOOL)flag
{
    NSData *data;
    
    data = [[self alloc] initWithGSSBufferNoCopy:buffer freeWhenDone:flag];
    
#if !__has_feature(objc_arc)
    [data autorelease];
#endif

    return data;
}

- (instancetype)initWithGSSBufferNoCopy:(gss_buffer_t)buffer freeWhenDone:(BOOL)flag
{
    if ((self = [super init]) == nil) {
        if (flag) {
            OM_uint32 minor;
            gss_release_buffer(&minor, buffer);
        }
        return nil;
    }
    
    _freeIt = flag;
    _data = *buffer;
    
    return self;
}

- (gss_buffer_desc)_gssBuffer
{
    return _data;
}

- (const void *)bytes
{
    return _data.value;
}

- (NSUInteger)length
{
    return _data.length;
}

@end

@implementation NSData (GSSBufferHelper)
- (gss_buffer_desc)_gssBuffer
{
    gss_buffer_desc buffer;
    
    buffer.length = [self length];
    buffer.value = (void *)[self bytes];
    
    return buffer;
}
@end
