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
NSString * const GSSMajorStatusDescriptionKey = @"GSSMajorStatusDescriptionKey";
NSString * const GSSMinorStatusDescriptionKey = @"GSSMinorStatusDescriptionKey";

@implementation NSError (GSSKitErrorHelper)

+ (NSString *)_gssDisplayStatus:(OM_uint32)status
                           type:(int)statusType
                           mech:(GSSMechanism *)mech
{
    OM_uint32 major, minor, msgCtx;
    gss_buffer_desc errorMessage = GSS_C_EMPTY_BUFFER;
    
    major = gss_display_status(&minor, status, statusType,
                               mech ? (gss_OID)[mech oid] : GSS_C_NO_OID,
                               &msgCtx,
                               &errorMessage);
    if (GSS_ERROR(major) || !errorMessage.value)
        return nil;
    
    return [NSString stringWithGSSBuffer:&errorMessage freeWhenDone:YES];
}

+ (NSError *)GSSError:(OM_uint32)majorStatus
                     :(OM_uint32)minorStatus
                     :(GSSMechanism *)mech
{
    NSDictionary *userInfo = @{
                               GSSMajorStatusErrorKey : [NSNumber numberWithUnsignedInt:majorStatus],
                               GSSMinorStatusErrorKey : [NSNumber numberWithUnsignedInt:minorStatus],
                               GSSMajorStatusDescriptionKey : [self _gssDisplayStatus:majorStatus type:GSS_C_GSS_CODE mech:mech],
                               GSSMinorStatusDescriptionKey : [self _gssDisplayStatus:minorStatus type:GSS_C_MECH_CODE mech:mech]
                               };
    
    return [NSError errorWithDomain:@"org.h5l.GSS" code:(NSInteger)majorStatus userInfo:userInfo];
}

+ (NSError *)GSSError:(OM_uint32)majorStatus
                     :(OM_uint32)minorStatus
{
    return [self GSSError:majorStatus :minorStatus :nil];
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

- (BOOL)_gssError
{
    NSNumber *major = self.userInfo[GSSMajorStatusErrorKey];

    return GSS_ERROR(major.unsignedIntValue); 
}

@end
