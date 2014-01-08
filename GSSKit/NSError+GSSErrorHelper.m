//
//  NSError+GSSErrorHelper.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

GSSKIT_EXPORT NSString * const GSSMajorErrorCodeKey = @"kGSSMajorErrorCode";
GSSKIT_EXPORT NSString * const GSSMinorErrorCodeKey = @"kGSSMinorErrorCode";

#if 0
GSSKIT_EXPORT NSString * const GSSMajorErrorDescriptionKey = @"kGSSMajorErrorDescription";
GSSKIT_EXPORT NSString * const GSSMinorErrorDescriptionKey = @"kGSSMinorErrorDescription";
#endif

GSSKIT_EXPORT NSString * const GSSMechanismOIDKey = @"kGSSMechanismOID";
GSSKIT_EXPORT NSString * const GSSMechanismKey = @"kGSSMechanism";

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
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSString *majorDesc, *minorDesc;

    userInfo[GSSMajorErrorCodeKey] = [NSNumber numberWithUnsignedInt:majorStatus];
    userInfo[GSSMinorErrorCodeKey] = [NSNumber numberWithUnsignedInt:minorStatus];

    majorDesc = [self _gssDisplayStatus:majorStatus type:GSS_C_GSS_CODE mech:mech];
    if (majorDesc)
        userInfo[NSLocalizedDescriptionKey] = majorDesc;

    minorDesc = [self _gssDisplayStatus:minorStatus type:GSS_C_MECH_CODE mech:mech];
    if (minorDesc)
        userInfo[NSLocalizedFailureReasonErrorKey] = minorDesc;

    userInfo[GSSMechanismOIDKey] = mech && [mech oidString] ? [mech oidString] : @"no-mech";
    userInfo[GSSMechanismKey] = mech && [mech name] ? [mech name] : @"no mech given";
    
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
    NSNumber *major = self.userInfo[GSSMajorErrorCodeKey];
    
    return !!([major unsignedIntValue] & GSS_S_CONTINUE_NEEDED);
}

- (BOOL)_gssError
{
    NSNumber *major = self.userInfo[GSSMajorErrorCodeKey];

    return !!GSS_ERROR(major.unsignedIntValue);
}

- (BOOL)_gssPromptingNeeded
{
    NSNumber *major = self.userInfo[GSSMajorErrorCodeKey];

    return (GSS_ROUTINE_ERROR(major.unsignedIntValue) == GSS_S_NO_CRED ||
            (major.unsignedIntValue & GSS_S_PROMPTING_NEEDED));
}

@end
