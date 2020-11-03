//
//  CKAccount.h
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//
@import UIKit;
#import "CKYapDatabaseObject.h"

typedef NS_ENUM(int, CKAccountType) {
    CKAccountTypeNone        = 0,
    CKAccountTypeFacebook    = 1, // deprecated
    CKAccountTypeGoogleTalk  = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface CKAccount : CKYapDatabaseObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, readonly) CKAccountType accountType;

/** Whether or not user would like to auto fetch media messages */
@property (nonatomic, readwrite) BOOL disableAutomaticURLFetching;


/** Will return nil if accountType does not match class type. @see accountClassForAccountType: */
- (nullable instancetype)initWithUsername:(NSString*)username
                              accountType:(CKAccountType)accountType NS_DESIGNATED_INITIALIZER;

/** Will return a concrete subclass of CKAccount. @see accountClassForAccountType: */
+ (nullable __kindof CKAccount*)accountWithUsername:(NSString*)username
                                         accountType:(CKAccountType)accountType;

/** Not available, use designated initializer */
- (instancetype) init NS_UNAVAILABLE;

+ (NSArray <CKAccount *>*)allAccountsWithUsername:(NSString *)username transaction:(YapDatabaseReadTransaction*)transaction;
+ (NSArray <CKAccount *>*)allAccountsWithTransaction:(YapDatabaseReadTransaction*)transaction;
+ (NSUInteger) numberOfAccountsWithTransaction:(YapDatabaseReadTransaction*)transaction;

/**
 Remove all accounts with account type using a read/write transaction
 
 @param accountType the account type to remove
 @param transaction a readwrite yap transaction
 @return the number of accounts removed
 */
+ (NSUInteger)removeAllAccountsOfType:(CKAccountType)accountType inTransaction:(YapDatabaseReadWriteTransaction *)transaction;

@end
NS_ASSUME_NONNULL_END
