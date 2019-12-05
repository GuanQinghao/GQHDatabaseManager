//
//  GQHDatabaseManager.h
//  Seed
//
//  Created by Mac on 2019/11/18.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface GQHDatabaseManager : NSObject

/// 数据库管理单例
+ (instancetype)qh_sharedDatabaseManager;

//MARK:数据库操作
/// 创建数据库文件
/// @param databaseName 数据库文件名
/// @param path 数据库文件路径
- (BOOL)qh_createDatabase:(NSString *)databaseName atPath:(nullable NSString *)path;

/// 删除数据库文件(不能删除非空数据库, 先删除数据表再删数据库)
/// @param databaseName 数据库文件名
/// @param path 数据库文件路径
- (BOOL)qh_removeDatabase:(NSString *)databaseName atPath:(nullable NSString *)path;

/// 数据库文件路径(Documents文件夹下, 已存在的数据库, 不存在则返回nil)
/// @param databaseName 数据库文件名
- (nullable NSString *)qh_pathOfDatabase:(NSString *)databaseName;

//MARK:数据表操作
/// 创建数据表
/// @param databaseName 数据库文件名
/// @param tableName 数据表名
/// @param cls 数据表对应的模型类
- (BOOL)qh_createTableInDatabase:(NSString *)databaseName withTableName:(NSString *)tableName model:(Class)cls;

/// 清空数据库中的数据表
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_truncateTable:(NSString *)tableName inDatabase:(NSString *)databaseName;

/// 删除数据库中的数据表
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_dropTable:(NSString *)tableName inDatabase:(NSString *)databaseName;

//MARK:CRUD
/// 插入数据
/// @param model 数据模型
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_insertData:(id)model inTable:(NSString *)tableName database:(NSString *)databaseName;

/// 查询指定属性指定值的数据
/// @param cls 数据表对应的模型类
/// @param key 指定属性
/// @param value 指定值
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (NSArray *)qh_queryOneWithClass:(Class)cls key:(NSString *)key value:(NSString *)value inTable:(NSString *)tableName database:(NSString *)databaseName;

/// 查询数据表中的所有数据
/// @param cls 数据表对应的模型类
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (NSArray *)qh_queryAllWithClass:(Class)cls inTable:(NSString *)tableName database:(NSString *)databaseName;

/// 删除指定属性指定值的数据
/// @param key 指定属性
/// @param value 指定值
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_deleteDataWithKey:(NSString *)key value:(NSString *)value inTable:(NSString *)tableName database:(NSString *)databaseName;

@end

NS_ASSUME_NONNULL_END
