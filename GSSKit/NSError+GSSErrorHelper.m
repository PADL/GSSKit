//
//  NSError+GSSErrorHelper.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

NSString * const GSSMajorStatusErrorKey = @"GSSMajorStatusErrorKey";
NSString * const GSSMinorStatusErrorKey = @"GSSMinorStatusErrorKey";

@implementation NSError (GSSErrorHelper)

+ (NSError *)GSSError:(OM_uint32)majorStatus
                     :(OM_uint32)minorStatus
{
    NSDictionary *userInfo = @{
                               GSSMajorStatusErrorKey : [NSNumber numberWithUnsignedInt:majorStatus],
                               GSSMinorStatusErrorKey : [NSNumber numberWithUnsignedInt:minorStatus]
                               };
    
    return [NSError errorWithDomain:@"org.h5l.GSS" code:(NSInteger)majorStatus userInfo:userInfo];
}

+ (NSError *)GSSError:(OM_uint32)majorStatus
{
    return [self GSSError:majorStatus :0];
}

- (BOOL)_gssContinueNeeded
{
    NSNumber *major = self.userInfo[GSSMajorStatusErrorKey];
    
    return ([major unsignedIntValue] == GSS_S_CONTINUE_NEEDED);
}

- (BOOL)_gssCompleteOrContinueNeeded
{
    NSNumber *major = self.userInfo[GSSMajorStatusErrorKey];
    
    return ([major unsignedIntValue] == GSS_S_COMPLETE ||
            [major unsignedIntValue] == GSS_S_CONTINUE_NEEDED);
}

@end
