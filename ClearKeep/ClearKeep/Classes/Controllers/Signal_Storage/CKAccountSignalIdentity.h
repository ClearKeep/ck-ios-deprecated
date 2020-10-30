//
//  CKSignalIdentity.h
//
//  Created by David Chiles on 7/21/16.
//  Copyright © 2016 Chris Ballinger. All rights reserved.
//

#import "CKSignalObject.h"
@class SignalIdentityKeyPair;

NS_ASSUME_NONNULL_BEGIN

/** There should only be one CKSignalIdentity in the database for an account */
@interface CKAccountSignalIdentity : CKSignalObject

@property (nonatomic, strong) SignalIdentityKeyPair *identityKeyPair;
@property (nonatomic) uint32_t registrationId;

- (nullable instancetype)initWithAccountKey:(NSString *)accountKey identityKeyPair:(SignalIdentityKeyPair *)identityKeyPair registrationId:(uint32_t)registrationId;

@end
NS_ASSUME_NONNULL_END
