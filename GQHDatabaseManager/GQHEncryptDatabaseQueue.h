//
//  GQHEncryptDatabaseQueue.h
//  Seed
//
//  Created by Mac on 2019/12/10.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import "FMDatabaseQueue.h"


NS_ASSUME_NONNULL_BEGIN

@interface GQHEncryptDatabaseQueue : FMDatabaseQueue

/// 加密数据库队列
/// @param aPath 数据库路径
/// @param encryptKey 密钥
+ (instancetype)databaseQueueWithPath:(NSString *)aPath encryptKey:(nullable NSString *)encryptKey;

@end

NS_ASSUME_NONNULL_END
