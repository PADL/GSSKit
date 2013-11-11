//
//  GSSItem+AcquireCredGlue.h
//  GSSKit
//
//  Created by Luke Howard on 11/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

#import "GSSKit_Private.h"

@interface GSSItem (AcquireCredGlue)

- (void)_itemAcquireOperation:(NSDictionary *)options
                        queue:(dispatch_queue_t)queue
            completionHandler:(void (^)(GSSCredential *, NSError *))fun;

@end
