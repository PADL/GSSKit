//
//  GSSKit_Private.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit.h"
#import "GSSPlaceholderItem.h"
#import "GSSPlaceholderName.h"
#import "GSSPlaceholderCredential.h"
#import "GSSItem_Private.h"

@interface NSError (GSSKit)
+ (NSError *)gssError:(OM_uint32)majorStatus :(OM_uint32)minorStatus;
+ (NSError *)gssError:(OM_uint32)majorStatus;
@end