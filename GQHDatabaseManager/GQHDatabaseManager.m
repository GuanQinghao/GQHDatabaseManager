//
//  GQHDatabaseManager.m
//  Seed
//
//  Created by Mac on 2019/11/18.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import "GQHDatabaseManager.h"
#import <FMDB/FMDB.h>
#import <objc/message.h>


/// 分页查询默认每页数量
static NSString * const kPageSize = @"1000";
/// 数据表固定主键值(model中手动添加此属性)
static NSString * const kDatabasePrimaryKey = @"db_id_pk";
/// 数据库管理单例
static GQHDatabaseManager *manager = nil;

@interface GQHDatabaseManager ()

/**
 数据库队列
 */
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation GQHDatabaseManager

/// 数据库管理单例
+ (instancetype)qh_sharedDatabaseManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[super allocWithZone:NULL] init];
    });
    
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [[self class] qh_sharedDatabaseManager];
}

//MARK:数据库操作
/// 创建数据库文件
/// @param databaseName 数据库文件名
/// @param path 数据库文件路径
- (BOOL)qh_createDatabase:(NSString *)databaseName atPath:(NSString *)path {
    
    if (databaseName && databaseName.length > 0) {
        
        // 数据库文件全路径
        NSString *databasePath = [self databaseName:databaseName atPath:path];
        NSLog(@"数据库文件路径:%@",databasePath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
            
            // 创建数据库文件
            return [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
        }
    }
    
    return NO;
}

/// 删除数据库文件(不能删除非空数据库)
/// @param databaseName 数据库文件名
/// @param path 数据库文件路径
- (BOOL)qh_removeDatabase:(NSString *)databaseName atPath:(NSString *)path {
    
    if (databaseName && databaseName.length > 0) {
        
        // 数据库文件全路径
        NSString *databasePath = [self databaseName:databaseName atPath:path];
        NSLog(@"数据库文件路径:%@",databasePath);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
            
            // 数据库队列
            self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
            // 数据表名
            __block NSString *tableNames = @"";
            
            if (self.databaseQueue) {
                
                [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    
                    // 查询数据库所有数据表名
                    NSString *tablesSQL = @"SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;";
                    
                    FMResultSet *resultSet = [db executeQuery: tablesSQL];
                    
                    while ([resultSet next]) {
                        
                        [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            
                            tableNames = [tableNames stringByAppendingFormat:@" %@", obj];
                        }];
                    }
                }];
                
                if (tableNames.length > 0) {
                    
                    NSLog(@"table name:%@.",tableNames);
                    
                    return NO;
                }
            }
            
            // 删除前手动关闭数据库
            [self.databaseQueue close];
            
            return [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        }
    }
    
    return NO;
}

/// 数据库文件全路径
/// @param name 数据库名
/// @param path 数据库文件路径
- (NSString *)databaseName:(NSString *)name atPath:(NSString *)path {
    
    if (path.length > 0) {
        
        // 是否是文件夹目录
        BOOL isDirectory = false;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
            
            if (isDirectory) {
                
                // 存在且是文件夹
                return [path stringByAppendingPathComponent:name];
            }
        }
        
        // 不是文件夹或不存在
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            // 创建路径成功
            return [path stringByAppendingPathComponent:name];
        }
    }
    
    // 路径为空或创建失败
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:name];
}

/// 数据库文件路径(已存在的数据库,不存在则返回nil)
/// @param databaseName 数据库文件名
- (NSString *)qh_pathOfDatabase:(NSString *)databaseName {
    
    NSMutableArray *filePaths = [NSMutableArray array];
    // 遍历Documents文件夹
    [self allFilePaths:filePaths atPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject];
    
    for (NSString *path in filePaths) {
        
        NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
        if ([fileName isEqualToString:databaseName]) {
            
            return path;
        }
    }
    
    return nil;
}

/// 遍历文件夹目录
/// @param filePaths 文件路径
/// @param path 文件夹目录
- (void)allFilePaths:(NSMutableArray *)filePaths atPath:(NSString *)path {
    
    // 是否是文件夹目录
    BOOL isDirectory = false;
    // 是否存在
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    if (isExist) {
        
        if (isDirectory) {
            
            // 文件夹下的所有文件及文件夹
            NSArray *directoryArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            
            for (NSString *name in directoryArray) {
                
                // 忽略隐藏的文件或文件夹
                if ([name hasPrefix:@"."]) {
                    
                    continue;
                }
                
                // 递归遍历
                [self allFilePaths:filePaths atPath:[path stringByAppendingPathComponent:name]];
            }
        } else {
            
            // 文件路径
            [filePaths addObject:path];
        }
    }
}

//MARK:数据表操作
/// 创建数据表
/// @param databaseName 数据库文件名
/// @param tableName 数据表名
/// @param cls 数据表对应的模型类
- (BOOL)qh_createTableInDatabase:(NSString *)databaseName withTableName:(NSString *)tableName model:(Class)cls {
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    // 数据表是否创建成功
    __block BOOL success = NO;
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 存在, 检查数据表
                // 所有字段
                NSMutableArray *fields = [NSMutableArray array];
                
                NSString *fieldsSQL = [NSString stringWithFormat:@"PRAGMA table_info([%@])",tableName];
                FMResultSet *resultSet = [db executeQuery:fieldsSQL];
                
                while ([resultSet next]) {
                    
                    [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        
                        if ([key isEqualToString:@"name"]) {
                            
                            [fields addObject:obj];
                        }
                    }];
                }
                
                // 所有属性
                NSMutableArray *properties = [NSMutableArray array];
                // 属性个数
                unsigned int count = 0;
                // 属性列表
                objc_property_t *propertyList = class_copyPropertyList([cls class], &count);
                
                for (int i = 0; i < count; i++) {
                    
                    // 第i个属性
                    objc_property_t property = propertyList[i];
                    // 属性名
                    const char *name = property_getName(property);
                    // 数据库字段名
                    NSString *field = [NSString stringWithUTF8String:name];
                    [properties addObject:field];
                }
                
                // 释放
                free(propertyList);
                
                //TODO:匹配
                success = [fields isEqualToArray:properties];
            } else {
                
                // 不存在, 创建数据表
                success = [db executeUpdate:[self sql_createTable:tableName model:cls]];
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return success;
}

/// 清空数据库中的数据表
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_truncateTable:(NSString *)tableName inDatabase:(NSString *)databaseName {
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    // 数据表是否清空成功
    __block BOOL success = NO;
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 清空数据表
                NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM '%@';",tableName];
                
                success = [db executeUpdate: deleteSQL];
            } else {
                
                NSLog(@"数据库%@中数据表%@不存在!",databaseName, tableName);
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return success;
}

/// 删除数据库中的数据表
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_dropTable:(NSString *)tableName inDatabase:(NSString *)databaseName {
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    // 数据表是否删除成功
    __block BOOL success = NO;
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 删除数据表
                NSString *dropSQL = [NSString stringWithFormat:@"DROP TABLE '%@';", tableName];
                
                success = [db executeUpdate: dropSQL];
            } else {
                
                NSLog(@"数据库%@中数据表%@不存在!",databaseName, tableName);
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return success;
}

//MARK:CRUD
/// 插入数据
/// @param model 数据模型
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_insertData:(id)model inTable:(NSString *)tableName database:(NSString *)databaseName {
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    // 数据表是否插入数据成功
    __block BOOL success = NO;
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 插入数据
                success = [db executeUpdate: [self sql_insertData:model inTable:tableName database:databaseName]];
            } else {
                
                NSLog(@"数据库%@中数据表%@不存在!",databaseName, tableName);
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return success;
}

/// 查询指定属性指定值的数据
/// @param cls 数据表对应的模型类
/// @param key 指定属性
/// @param value 指定值
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (NSArray *)qh_queryOneWithClass:(Class)cls key:(NSString *)key value:(NSString *)value inTable:(NSString *)tableName database:(NSString *)databaseName {
    
    //TODO:分页查询
//    SELECT * FROM 'order' ORDER BY db_id_pk LIMIT 1000 OFFSET (3*1000);
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    
    // 查询结果
    NSMutableArray *models = [NSMutableArray array];
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 查询数据
                NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE %@ = '%@';",tableName,key,value];
                
                FMResultSet *resultSet = [db executeQuery:querySQL];
                
                // 遍历
                while ([resultSet next]) {
                    
                    // 模型
                    id model = [[cls class] new];
                    // 属性个数
                    unsigned int count = 0;
                    // 属性列表
                    objc_property_t *propertyList = class_copyPropertyList([cls class], &count);
                    
                    for (int i = 0; i < count; i++) {
                        
                        // 第i个属性
                        objc_property_t property = propertyList[i];
                        // 属性名
                        const char *name = property_getName(property);
                        // 数据库字段名
                        NSString *field = [NSString stringWithUTF8String:name];
                        // NSNumber, NSString, NSData, NSNull,[NSNull null]
                        id value = [resultSet objectForColumn:field];
                        //
                        [model setValue:value forKey:field];
                    }
                    
                    // 释放
                    free(propertyList);
                    
                    // 保存到数组中
                    [models addObject:model];
                }
            } else {
                
                NSLog(@"数据库%@中数据表%@不存在!",databaseName, tableName);
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return models;
}

/// 查询数据表中的所有数据
/// @param cls 数据表对应的模型类
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (NSArray *)qh_queryAllWithClass:(Class)cls inTable:(NSString *)tableName database:(NSString *)databaseName {
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    
    // 查询结果
    NSMutableArray *models = [NSMutableArray array];
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 查询数据
                NSString *allSQL = [NSString stringWithFormat:@"SELECT * FROM '%@';",tableName];
                
                FMResultSet *resultSet = [db executeQuery:allSQL];
                
                // 遍历
                while ([resultSet next]) {
                    
                    // 模型
                    id model = [[cls class] new];
                    // 属性个数
                    unsigned int count = 0;
                    // 属性列表
                    objc_property_t *propertyList = class_copyPropertyList([cls class], &count);
                    
                    for (int i = 0; i < count; i++) {
                        
                        // 第i个属性
                        objc_property_t property = propertyList[i];
                        // 属性名
                        const char *name = property_getName(property);
                        // 数据库字段名
                        NSString *field = [NSString stringWithUTF8String:name];
                        // NSNumber, NSString, NSData, NSNull,[NSNull null]
                        id value = [resultSet objectForColumn:field];
                        //
                        [model setValue:value forKey:field];
                    }
                    
                    // 释放
                    free(propertyList);
                    
                    // 保存到数组中
                    [models addObject:model];
                }
            } else {
                
                NSLog(@"数据库%@中数据表%@不存在!",databaseName, tableName);
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return models;
}

/// 删除指定属性指定值的数据
/// @param key 指定属性
/// @param value 指定值
/// @param tableName 数据表名
/// @param databaseName 数据库文件名
- (BOOL)qh_deleteDataWithKey:(NSString *)key value:(NSString *)value inTable:(NSString *)tableName database:(NSString *)databaseName {
    
    // 数据库文件路径
    NSString *databasePath = [self qh_pathOfDatabase:databaseName];
    // 数据表是否删除成功
    __block BOOL success = NO;
    
    if (databasePath && databasePath.length > 0) {
        
        // 数据库队列
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            if ([db tableExists:tableName]) {
                
                // 删除数据
                NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ = '%@';",tableName,key,value];
                
                success = [db executeUpdate: deleteSQL];
            } else {
                
                NSLog(@"数据库%@中数据表%@不存在!",databaseName, tableName);
            }
        }];
    } else {
        
        NSLog(@"数据库%@不存在!",databaseName);
    }
    
    return success;
}

//MARK:SQLite
/// SQL语句-创建数据表
/// @param tableName 数据表名
- (NSString *)sql_createTable:(NSString *)tableName model:(id)model {
    
    // 数据库全部采用TEXT类型
    NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY NOT NULL UNIQUE", tableName, kDatabasePrimaryKey];
    
    // 属性个数
    unsigned int count = 0;
    // 属性列表
    objc_property_t *propertyList = class_copyPropertyList([model class], &count);
    
    for (int i = 0; i < count; i++) {
        
        // 第i个属性
        objc_property_t property = propertyList[i];
        // 属性名
        const char *name = property_getName(property);
        // 数据库字段名
        NSString *field = [NSString stringWithUTF8String:name];
        
        if ([field isEqualToString:kDatabasePrimaryKey]) {
            
            // 排除主键
            continue;
        }
        
        sqlString = [sqlString stringByAppendingFormat:@", %@ TEXT",field];
    }
    
    // 释放
    free(propertyList);
    
    sqlString = [sqlString stringByAppendingString:@");"];
    
    return sqlString;
}

/// SQL语句-插入数据
/// @param model 数据模型
/// @param tableName 数据表名
/// @param databaseName 数据库名
- (NSString *)sql_insertData:(id)model inTable:(NSString *)tableName database:(NSString *)databaseName {
    
    // SQL语句
    // INSERT INTO 'table_name' ('db_id_pk','name','age') VALUES (NULL,'allen','29');
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO '%@' ('%@'", tableName, kDatabasePrimaryKey];
    
    // 属性个数
    unsigned int count = 0;
    // 属性列表
    objc_property_t *propertyList = class_copyPropertyList([model class], &count);
    // 属性数组
    NSMutableArray *keys = [NSMutableArray array];
    
    // 拼接字段
    for (int i = 0; i < count; i++) {
        
        // 第i个属性
        objc_property_t property = propertyList[i];
        // 属性名
        const char *name = property_getName(property);
        // 数据库字段名
        NSString *field = [NSString stringWithUTF8String:name];
        
        // 数据库字段值
        NSString *value = [NSString stringWithFormat:@"%@", [model valueForKey:field]];
        
        if ([field isEqualToString:kDatabasePrimaryKey]) {
            
            // 排除主键
            continue;
        }
        
        if (value && value.length > 0) {
            
            // 保存键
            [keys addObject:field];
            
            // 对应有值的字段
            sqlString = [sqlString stringByAppendingFormat:@",'%@'",field];
        }
    }
    
    // 释放
    free(propertyList);
    
    sqlString = [sqlString stringByAppendingString:@") VALUES (NULL"];
    
    // 拼接值
    for (int i = 0; i < keys.count; i++) {
        
        NSString *key = keys[i];
        
        // 字段对应的值
        id object = [model valueForKey:key];
        
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            
            // 字符串类型、数字对象类型
            sqlString = [sqlString stringByAppendingFormat:@",'%@'",object];
        } else {
            
            // 其他
            sqlString = [sqlString stringByAppendingFormat:@",NULL"];
        }
    }
    
    return [sqlString stringByAppendingString:@");"];
}

@end
