//
//  SeedDatabaseManager.h
//  Seed
//
//  Created by Hao on 2020/11/15.
//  Copyright © 2020 GuanQinghao. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/// 数据库结构体
typedef struct _SeedDatabase {
    
    // 数据库绝对路径, 默认为Documents文件夹
    NSString *db_path;
    // 数据库名
    NSString *db_name;
    // 数据表名
    NSString *db_table;
    // 数据库密钥, 默认为空表示不加密
    NSString *db_encrypt_key;
    // 存储的模型类
    Class db_cls;
} SeedDatabase;

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

/// 数据库操作条件结构体
typedef struct _SeedSQLiteCondition {
    
    // 数据库结构体
    SeedDatabase db_database;
    // 页大小
    NSInteger db_size;
    // 页码
    NSInteger db_page;
    // 查询条件
    NSDictionary *db_query;
} SeedSQLiteCondition;

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface SeedDatabaseManager : NSObject

/// 数据库管理单例
@property (class, readonly, strong) SeedDatabaseManager *s_sharedDatabaseManager;

/// 数据库管理单例
+ (instancetype)s_sharedDatabaseManager;


#pragma mark ----------------------------- <数据库> -----------------------------

/// 创建数据库
/// @param database 数据库结构体
- (BOOL)s_createDatabase:(SeedDatabase)database;

/// 清空数据表
/// @param database 数据库结构体
- (BOOL)s_truncateDatabase:(SeedDatabase)database;

/// 删除数据表(不能删除非空数据表, 先清空数据表, 再删除数据表)
/// @param database 数据库结构体
- (BOOL)s_dropDatabase:(SeedDatabase)database;

/// 删除数据库(不能删除非空数据库, 先清空数据表, 再删除数据表, 最后删除数据库)
/// @param database 数据库结构体
- (BOOL)s_removeDatabase:(SeedDatabase)database;

/// 数据库文件路径(Documents文件夹下, 已存在的数据库)
/// @param databaseName 数据库文件名
- (NSArray<NSString *> *)s_filePathWithDatabaseName:(NSString *)databaseName;

/// 查询数据库所有数据表名称
/// @param database 数据库结构体
- (nullable NSArray<NSString *> *)s_allTableNamesInDatabase:(SeedDatabase)database;

/// 查询数据库中数据表的记录总数
/// @param database 数据库结构体
- (NSInteger)s_totalNumberInDatabase:(SeedDatabase)database;

#pragma mark ----------------------------- <CRUD> -----------------------------

/// 插入数据
/// @param model 模型数据
/// @param database 数据库结构体
- (BOOL)s_insertData:(id)model intoDatabase:(SeedDatabase)database;

/// 更新数据
/// @param model 修改后的模型数据
/// @param database 数据库结构体
- (BOOL)s_updateData:(id)model inDatabase:(SeedDatabase)database;

/// 删除数据
/// @param condition 数据库操作条件结构体
- (BOOL)s_deleteDataWith:(SeedSQLiteCondition)condition;

/// 查询数据
/// @param condition 数据库操作条件结构体
- (nullable NSArray *)s_queryDataWith:(SeedSQLiteCondition)condition;

/// 模糊查询数据
/// @param condition 数据库操作条件结构体
- (nullable NSArray *)s_fuzzyQueryDataWith:(SeedSQLiteCondition)condition;

@end

NS_ASSUME_NONNULL_END
