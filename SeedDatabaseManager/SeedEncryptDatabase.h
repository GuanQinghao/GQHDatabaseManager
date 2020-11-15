//
//  SeedEncryptDatabase.h
//  Seed
//
//  Created by Hao on 2020/11/15.
//  Copyright © 2020 GuanQinghao. All rights reserved.
//

#import <FMDatabase.h>


NS_ASSUME_NONNULL_BEGIN

@interface SeedEncryptDatabase : FMDatabase

/// 创建加密数据库
/// @param aPath 数据库路径
/// @param encryptKey 密钥
+ (instancetype)databaseWithPath:(NSString *)aPath encryptKey:(nullable NSString *)encryptKey;

/// 创建加密数据库
/// @param aPath 数据库路径
/// @param encryptKey 密钥
- (instancetype)initWithPath:(NSString *)aPath encryptKey:(nullable NSString *)encryptKey;

@end

NS_ASSUME_NONNULL_END
