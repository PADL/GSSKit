//
//  GSSCredential.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

@interface GSSCredential : NSObject

// primitive methods

- (id)initWithName:(GSSName *)name
         mechanism:(GSSMechanism *)desiredMech
        attributes:(NSDictionary *)attributes
             error:(NSError **)error;

- (gss_cred_id_t)_gssCred;

// category methods

- (GSSName *)name;
- (OM_uint32)lifetime;
- (OM_uint32)credUsage;
- (NSArray *)mechanisms;
- (NSData *)export;


@end