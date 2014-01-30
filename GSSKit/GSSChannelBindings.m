//
//  GSSChannelBindings.m
//  GSSKit
//
//  Created by Luke Howard on 8/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@implementation GSSChannelBindings

@synthesize initiatorAddressType = _initiatorAddressType;
@synthesize initiatorAddress = _initiatorAddress;
@synthesize acceptorAddressType = _acceptorAddressType;
@synthesize acceptorAddress = _acceptorAddress;
@synthesize applicationData = _applicationData;

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithUnsignedInt:self.initiatorAddressType] forKey:@"initiatorAddressType"];
    [coder encodeObject:self.initiatorAddress forKey:@"initiatorAddress"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:self.acceptorAddressType] forKey:@"acceptorAddressType"];
    [coder encodeObject:self.acceptorAddress forKey:@"acceptorAddress"];
    [coder encodeObject:self.applicationData forKey:@"applicationData"];

}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init]) == nil)
        return nil;

    self.initiatorAddressType = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"initiatorAddressType"] unsignedIntValue];
    self.initiatorAddress = [coder decodeObjectOfClass:[NSData class] forKey:@"initiatorAddress"];
    self.acceptorAddressType = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"acceptorAddressType"] unsignedIntValue];
    self.acceptorAddress = [coder decodeObjectOfClass:[NSData class] forKey:@"acceptorAddress"];
    self.applicationData = [coder decodeObjectOfClass:[NSData class] forKey:@"applicationData"];
    
    return self;
}

@end
