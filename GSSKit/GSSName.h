//
//  GSSName.h
//  GSSKit
//
//  Created by Luke Howard on 7/11/2013.
//  Copyright (c) 2013 PADL Software Pty Ltd. All rights reserved.
//

__attribute__((visibility("default")))
@interface GSSName : NSObject <NSSecureCoding, NSCopying>

+ (GSSName *)nameWithHostBasedService:(NSString *)name;
+ (GSSName *)nameWithHostBasedService: (NSString *)service withHostName: (NSString *)hostname;
+ (GSSName *)nameWithUserName: (NSString *)username;
+ (GSSName *)nameWithExportedData:(NSData *)name;
+ (GSSName *)nameWithURL:(NSURL *)url;

- (NSData *)exportName;
- (NSString *)displayString;
- (BOOL)isEqualToName:(GSSName *)name;
- (GSSName *)mechanismName:(GSSMechanism *)mechanism;

@end
