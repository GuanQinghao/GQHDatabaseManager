//
//  GQHDatabaseManager.h
//  Seed
//
//  Created by Mac on 2019/11/18.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/// 数据库结构体
typedef struct _GQHDatabase {
    
    NSString *db_path;// 数据库路径, 默认为Documents文件夹
    NSString *db_name;// 数据库名
    NSString *db_table;// 数据表名
    Class db_cls;// 存储的模型类
} GQHDatabase;

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

/// 数据库操作条件结构体
typedef struct _GQHSQLiteCondition {
    
    GQHDatabase db_database;// 数据库结构体
    NSInteger db_size;// 页大小
    NSInteger db_page;// 页码
    NSDictionary *db_query;// 查询条件
} GQHSQLiteCondition;

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface GQHDatabaseManager : NSObject

/**
 数据库管理单例
 */
@property (class, readonly, strong) GQHDatabaseManager *qh_sharedDatabaseManager;

/// 数据库管理单例
+ (instancetype)qh_sharedDatabaseManager;

/// 创建数据库
/// @param database 数据库结构体
- (BOOL)qh_createDatabase:(GQHDatabase)database;

/// 数据库文件路径(Documents文件夹下, 已存在的数据库, 不存在则返回nil)
/// @param databaseName 数据库文件名
- (nullable NSString *)qh_filePathWithDatabaseName:(NSString *)databaseName;

/// 查询数据库所有数据表名称
/// @param database 数据库结构体
- (NSArray<NSString *> *)qh_queryAllTableNamesInDatabase:(GQHDatabase)database;

/// 删除数据库(不能删除非空数据库, 先清空数据表, 再删除数据表, 最后删除数据库)
/// @param database 数据库结构体
- (BOOL)qh_removeDatabase:(GQHDatabase)database;

/// 删除数据表(不能删除非空数据表, 先清空数据表, 再删除数据表)
/// @param database 数据库结构体
- (BOOL)qh_dropDatabase:(GQHDatabase)database;

/// 清空数据表
/// @param database 数据库结构体
- (BOOL)qh_truncateDatabase:(GQHDatabase)database;

//MARK:CRUD
/// 插入数据
/// @param model 模型数据
/// @param database 数据库结构体
- (BOOL)qh_insertData:(id)model intoDatabase:(GQHDatabase)database;

/// 删除数据
/// @param condition 数据库操作条件结构体
- (BOOL)qh_deleteDataWith:(GQHSQLiteCondition)condition;

/// 查询数据
/// @param condition 数据库操作条件结构体
- (NSArray *)qh_queryDataWith:(GQHSQLiteCondition)condition;

///TODO: 模糊查询数据
/// @param condition 数据库操作条件结构体
- (NSArray *)qh_fuzzyQueryDataWith:(GQHSQLiteCondition)condition;

@end

NS_ASSUME_NONNULL_END
