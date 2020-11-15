//
//  SeedEncryptDatabaseQueue.h
//  Seed
//
//  Created by Hao on 2020/11/15.
//  Copyright © 2020 GuanQinghao. All rights reserved.
//

#import <FMDatabaseQueue.h>


NS_ASSUME_NONNULL_BEGIN

@interface SeedEncryptDatabaseQueue : FMDatabaseQueue

/// 加密数据库队列
/// @param aPath 数据库路径
/// @param encryptKey 密钥
+ (instancetype)s_databaseQueueWithPath:(NSString *)aPath encryptKey:(nullable NSString *)encryptKey;

@end

NS_ASSUME_NONNULL_END
