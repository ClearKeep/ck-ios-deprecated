//
//  CKSignalObject.h
//
//  Created by David Chiles on 7/26/16.
//  Copyright © 2016 Chris Ballinger. All rights reserved.
//

#import "CKYapDatabaseObject.h"
@import YapDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface CKSignalObject : CKYapDatabaseObject <YapDatabaseRelationshipNode>

@property (nonnull, strong) NSString *accountKey;

@end

NS_ASSUME_NONNULL_END
