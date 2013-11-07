//
//  GSSName.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSName : NSObject
+ (GSSName *)nameWithData:(NSData *)data
                 nameType:(gss_const_OID)nameType
                    error:(NSError **)error;

- (id)initWithName:(GSSName *)name
         mechanism:(gss_const_OID)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError **)error;
@end
