//
//  SeedDatabaseManager.m
//  Seed
//
//  Created by Hao on 2020/11/15.
//  Copyright © 2020 GuanQinghao. All rights reserved.
//

#import "SeedDatabaseManager.h"
#import <objc/message.h>
#import <FMDB/FMDB.h>
#import "SeedEncryptDatabase.h"
#import "SeedEncryptDatabaseQueue.h"


#ifdef DEBUG
#define NSLog(format, ...)  printf("[%s] [%s] %s [%d] %s\n",[[[NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSinceNow:(8 * 60 * 60)]] substringToIndex:19] UTF8String],[[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__FUNCTION__] UTF8String],__LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(...)
#endif


/// 分页查询默认每页大小
static NSString * const kPageSize = @"1000";
/// 数据表固定主键值(model中手动添加此属性)
static NSString * const kDatabasePrimaryKey = @"db_pk_id";

@interface SeedDatabaseManager ()

/// 数据库队列
@property (nonatomic, strong) SeedEncryptDatabaseQueue *databaseQueue;

@end

@implementation SeedDatabaseManager

/// 数据库管理单例
+ (instancetype)s_sharedDatabaseManager {
    
    /// 数据库管理单例
    static SeedDatabaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[super allocWithZone:NULL] init];
    });
    
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [self s_sharedDatabaseManager];
}


#pragma mark ----------------------------- <数据库> -----------------------------

/// 创建数据库
/// @param database 数据库结构体
- (BOOL)s_createDatabase:(SeedDatabase)database {
    
    // 创建数据库是否成功
    __block BOOL success = NO;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    // 数据表对应模型类
    Class dbClass = database.db_cls;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        // 创建数据表
        success = [self createDatabaseTable:dbTable withClass:dbClass encryptKey:dbEncryptKey atPath:databasePath];
    } else {
        
        // 创建数据库文件
        if ([[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil]) {
            
            // 创建数据表
            success = [self createDatabaseTable:dbTable withClass:dbClass encryptKey:dbEncryptKey atPath:databasePath];
        } else {
            
            NSLog(@"%s [%d] [Failed to create a new database file: %@!]", __func__, __LINE__,databasePath);
        }
    }
    
    return success;
}

/// 清空数据表
/// @param database 数据库结构体
- (BOOL)s_truncateDatabase:(SeedDatabase)database {
    
    // 数据表是否清空成功
    __block BOOL success = NO;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 清空数据表
                    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM '%@';",dbTable];
                    NSLog(@"SQL:%@",deleteSQL);
                    success = [db executeUpdate: deleteSQL];
                } else {
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return success;
}

/// 删除数据表(不能删除非空数据表, 先清空数据表, 再删除数据表)
/// @param database 数据库结构体
- (BOOL)s_dropDatabase:(SeedDatabase)database {
    
    // 数据表是否删除成功
    __block BOOL success = NO;
    // 数据表是否是空表
    __block BOOL empty = NO;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 查询数据表记录条数
                    NSString *countSQL = [NSString stringWithFormat:@"SELECT count(%@) FROM '%@';", kDatabasePrimaryKey,dbTable];
                    NSLog(@"SQL:%@",countSQL);
                    FMResultSet *resultSet = [db executeQuery:countSQL];
                    while ([resultSet next]) {
                        
                        [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            
                            empty = !([obj integerValue] > 0);
                        }];
                    }
                    
                    if (empty) {
                        
                        // 删除空数据表
                        NSString *dropSQL = [NSString stringWithFormat:@"DROP TABLE '%@';", dbTable];
                        NSLog(@"SQL:%@",dropSQL);
                        success = [db executeUpdate: dropSQL];
                    } else {
                        
                        // 非空数据表
                        NSLog(@"%s [%d] [There is data in the data table: %@!]", __func__, __LINE__,dbTable);
                    }
                } else {
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return success;
}

/// 删除数据库(不能删除非空数据库, 先清空数据表, 再删除数据表, 最后删除数据库)
/// @param database 数据库结构体
- (BOOL)s_removeDatabase:(SeedDatabase)database {
    
    // 数据表是否删除成功
    __block BOOL success = NO;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        // 查询数据库中所有的数据表名
        NSArray<NSString *> *tableNames = [self s_allTableNamesInDatabase:database];
        if (tableNames.count > 0) {
            
            // 非空数据库
            NSString *tableNamesString = [tableNames componentsJoinedByString:@", "];
            NSLog(@"%s [%d] [The database has data table(s): %@!]", __func__, __LINE__,tableNamesString);
        } else {
            
            // 空数据库
            success = [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return success;
}

/// 数据库文件路径(Documents文件夹下, 已存在的数据库)
/// @param databaseName 数据库文件名
- (NSArray<NSString *> *)s_filePathWithDatabaseName:(NSString *)databaseName {
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSMutableArray<NSString *> *filePaths = [NSMutableArray array];
    // 遍历Documents文件夹
    [self allFilePaths:filePaths atPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject];
    [filePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *fileName = [[obj componentsSeparatedByString:@"/"] lastObject];
        if ([fileName isEqualToString:databaseName]) {
            
            [result addObject:obj];
        }
    }];
    
    return result.copy;
}

/// 查询数据库所有数据表名称
/// @param database 数据库结构体
- (NSArray<NSString *> *)s_allTableNamesInDatabase:(SeedDatabase)database {
    
    // 数据表名
    NSMutableArray<NSString *> *tableNames = [NSMutableArray array];
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return [tableNames copy];
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        // 数据库队列
        self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            // 查询数据库所有数据表名
            NSString *tablesSQL = @"SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;";
            NSLog(@"SQL:%@",tablesSQL);
            FMResultSet *resultSet = [db executeQuery: tablesSQL];
            while ([resultSet next]) {
                
                [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    
                    [tableNames addObject:obj];
                }];
            }
        }];
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return tableNames.copy;
}

/// 查询数据库中数据表的记录总数
/// @param database 数据库结构体
- (NSInteger)s_totalNumberInDatabase:(SeedDatabase)database {
    
    // 记录总数
    __block NSInteger result = 0;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return result;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        // 数据库队列
        self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            // 数据表名
            NSMutableArray<NSString *> *tableNames = [NSMutableArray array];
            
            // 查询数据库所有数据表名
            NSString *tablesSQL = @"SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;";
            NSLog(@"SQL:%@",tablesSQL);
            FMResultSet *resultSet = [db executeQuery: tablesSQL];
            while ([resultSet next]) {
                
                [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    
                    [tableNames addObject:obj];
                }];
            }
            
            if ([self isNonnullString:dbTable]) {
                
                // 数据库包含数据表
                if ([tableNames containsObject:dbTable]) {
                    
                    // 查询数据表记录条数
                    NSString *countSQL = [NSString stringWithFormat:@"SELECT count(%@) FROM '%@';", kDatabasePrimaryKey,dbTable];
                    NSLog(@"SQL:%@",countSQL);
                    FMResultSet *resultSet = [db executeQuery:countSQL];
                    while ([resultSet next]) {
                        
                        [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            
                            result += [obj integerValue];
                        }];
                    }
                }
            } else {
                
                // 查询所有数据表的记录总数
                [tableNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    // 查询数据表记录条数
                    NSString *countSQL = [NSString stringWithFormat:@"SELECT count(%@) FROM '%@';", kDatabasePrimaryKey,obj];
                    NSLog(@"SQL:%@",countSQL);
                    FMResultSet *resultSet = [db executeQuery:countSQL];
                    while ([resultSet next]) {
                        
                        [[resultSet resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            
                            result += [obj integerValue];
                        }];
                    }
                }];
            }
        }];
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return result;
}

/// 数据库文件全路径
/// @param name 数据库名
/// @param path 数据库文件路径
- (NSString *)databaseName:(NSString *)name atPath:(NSString *)path {
    
    if ([self isNonnullString:path]) {
        
        // 是否是文件夹目录
        BOOL isDirectory = NO;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
            
            if (isDirectory) {
                
                // 存在且是文件夹
                return [path stringByAppendingPathComponent:name];
            }
        }
        
        // 不是文件夹或不存在
        NSError *error;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            
            // 创建路径成功
            return [path stringByAppendingPathComponent:name];
        }
    }
    
    // 路径为空或创建失败
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:name];
}

/// 创建数据表
/// @param tableName 数据表名
/// @param cls 数据表对应的模型类
/// @param databasePath 数据库文件路径
- (BOOL)createDatabaseTable:(NSString *)tableName withClass:(Class)cls encryptKey:(NSString *)key atPath:(NSString *)databasePath {
    
    // 创建数据表是否成功
    __block BOOL success = NO;
    
    if (![self isNonnullString:tableName]) {
        
        NSLog(@"%s [%d] [The database table name is empty: %@!]", __func__, __LINE__,databasePath);
        return success;
    }
    
    // 数据库队列
    self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:key];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        if ([db tableExists:tableName]) {
            
            // 存在, 检查数据表
            // 所有字段
            NSMutableArray *fields = [NSMutableArray array];
            
            NSString *fieldsSQL = [NSString stringWithFormat:@"PRAGMA table_info([%@])",tableName];
            NSLog(@"SQL:%@",fieldsSQL);
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
            
            //TODO:匹配字段
            success = [fields isEqualToArray:properties];
        } else {
            
            // 不存在, 创建数据表
            success = [db executeUpdate:[self sql_createTable:tableName model:cls]];
        }
    }];
    
    return success;
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


#pragma mark ----------------------------- <CRUD> -----------------------------

/// 插入数据
/// @param model 模型数据
/// @param database 数据库结构体
- (BOOL)s_insertData:(id)model intoDatabase:(SeedDatabase)database {
    
    // 数据表是否插入数据成功
    __block BOOL success = NO;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 插入数据
                    NSString *insertSQL = [self sql_insertData:model intoTable:dbTable database:dbName];
                    NSLog(@"SQL:%@",insertSQL);
                    success = [db executeUpdate: insertSQL];
                } else {
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return success;
}

/// 更新数据
/// @param model 修改后的模型数据
/// @param database 数据库结构体
- (BOOL)s_updateData:(id)model inDatabase:(SeedDatabase)database {
    
    // 数据表是否插入数据成功
    __block BOOL success = NO;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 更新数据
                    NSString *updateSQL = [self sql_updateData:model inTable:dbTable database:dbName];
                    NSLog(@"SQL:%@",updateSQL);
                    success = [db executeUpdate: updateSQL];
                } else {
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return success;
}

/// 删除数据
/// @param condition 数据库操作条件结构体
- (BOOL)s_deleteDataWith:(SeedSQLiteCondition)condition {
    
    // 数据是否删除成功
    __block BOOL success = NO;
    
    // 数据库结构体
    SeedDatabase database = condition.db_database;
    // 条件
    NSDictionary *query = condition.db_query;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return success;
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 删除数据
                    NSString *deleteSQL = [self sql_deleteDataWith:query inTable:dbTable];
                    NSLog(@"SQL:%@",deleteSQL);
                    success = [db executeUpdate: deleteSQL];
                } else {
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return success;
}

/// 查询数据
/// @param condition 数据库操作条件结构体
- (NSArray *)s_queryDataWith:(SeedSQLiteCondition)condition {
    
    // 查询结果
    NSMutableArray *models = [NSMutableArray array];
    
    // 数据库结构体
    SeedDatabase database = condition.db_database;
    // 页大小
    NSInteger size = (condition.db_size > 0) ? condition.db_size : [kPageSize integerValue];
    // 页码
    NSInteger page = (condition.db_page > 1) ? condition.db_page : 1;
    // 条件
    NSDictionary *query = condition.db_query;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    // 数据表对应模型类
    Class dbClass = database.db_cls;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return [models copy];
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 查询数据
                    NSString *querySQL = [self sql_queryDataWith:query size:size page:page inTable:dbTable];
                    NSLog(@"SQL:%@",querySQL);
                    FMResultSet *resultSet = [db executeQuery:querySQL];
                    while ([resultSet next]) {
                        
                        // 模型
                        id model = [[dbClass class] new];
                        // 属性个数
                        unsigned int count = 0;
                        // 属性列表
                        objc_property_t *propertyList = class_copyPropertyList([dbClass class], &count);
                        
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
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return [models copy];
}

/// 模糊查询数据
/// @param condition 数据库操作条件结构体
- (NSArray *)s_fuzzyQueryDataWith:(SeedSQLiteCondition)condition {
    
    // 查询结果
    NSMutableArray *models = [NSMutableArray array];
    
    // 数据库结构体
    SeedDatabase database = condition.db_database;
    // 页大小
    NSInteger size = (condition.db_size > 0) ? condition.db_size : [kPageSize integerValue];
    // 页码
    NSInteger page = (condition.db_page > 1) ? condition.db_page : 1;
    // 条件
    NSDictionary *query = condition.db_query;
    
    // 数据库名
    NSString *dbName = database.db_name;
    // 数据库文件路径
    NSString *dbPath = database.db_path;
    // 数据表名
    NSString *dbTable = database.db_table;
    // 数据库密钥
    NSString *dbEncryptKey = database.db_encrypt_key;
    // 数据表对应模型类
    Class dbClass = database.db_cls;
    
    if (![self isNonnullString:dbName]) {
        
        NSLog(@"%s [%d] [The database name is empty!]", __func__, __LINE__);
        return [models copy];
    }
    
    // 数据库文件全路径
    NSString *databasePath = [self databaseName:dbName atPath:dbPath];
    NSLog(@"The database path:%@",databasePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        
        if ([self isNonnullString:dbTable]) {
            
            // 数据库队列
            self.databaseQueue = [SeedEncryptDatabaseQueue s_databaseQueueWithPath:databasePath encryptKey:dbEncryptKey];
            [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                if ([db tableExists:dbTable]) {
                    
                    // 查询数据
                    NSString *querySQL = [self sql_fuzzyQueryDataWith:query size:size page:page inTable:dbTable];
                    NSLog(@"SQL:%@",querySQL);
                    FMResultSet *resultSet = [db executeQuery:querySQL];
                    while ([resultSet next]) {
                        
                        // 模型
                        id model = [[dbClass class] new];
                        // 属性个数
                        unsigned int count = 0;
                        // 属性列表
                        objc_property_t *propertyList = class_copyPropertyList([dbClass class], &count);
                        
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
                    
                    NSLog(@"%s [%d] [The database table does not exist: %@!]", __func__, __LINE__,dbTable);
                }
            }];
        } else {
            
            NSLog(@"%s [%d] [The database table name is empty!]", __func__, __LINE__);
        }
    } else {
        
        NSLog(@"%s [%d] [The database file does not exist: %@!]", __func__, __LINE__,databasePath);
    }
    
    return [models copy];
}

#pragma mark - SQLite
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
        // 属性对应数据库的字段名
        NSString *field = [NSString stringWithUTF8String:name];
        // 排除主键
        if ([field isEqualToString:kDatabasePrimaryKey]) {
            
            continue;
        }
        
        sqlString = [sqlString stringByAppendingFormat:@", %@ TEXT",field];
    }
    
    // 释放
    free(propertyList);
    
    return [sqlString stringByAppendingString:@");"];
}

/// SQL语句-插入数据
/// @param model 数据模型
/// @param tableName 数据表名
/// @param databaseName 数据库名
- (NSString *)sql_insertData:(id)model intoTable:(NSString *)tableName database:(NSString *)databaseName {
    
    // SQL语句
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
        // 属性对应数据库的字段名
        NSString *field = [NSString stringWithUTF8String:name];
        // 排除主键
        if ([field isEqualToString:kDatabasePrimaryKey]) {
            
            continue;
        }
        
        // 属性值对应数据库的字段值
        NSString *value = [model valueForKey:field];
        if (value) {
            
            // 保存有值的键
            [keys addObject:field];
            
            // 对应有值的字段
            sqlString = [sqlString stringByAppendingFormat:@",'%@'",field];
        }
    }
    
    // 释放
    free(propertyList);
    
    sqlString = [sqlString stringByAppendingString:@") VALUES (NULL"];
    
    // 拼接有值的字段
    for (int i = 0; i < keys.count; i++) {
        
        NSString *key = keys[i];
        sqlString = [sqlString stringByAppendingFormat:@",'%@'",[model valueForKey:key]];
    }
    
    return [sqlString stringByAppendingString:@");"];
}

/// SQL语句-修改数据
/// @param model 数据模型
/// @param tableName 数据表名
/// @param databaseName 数据库名
- (NSString *)sql_updateData:(id)model inTable:(NSString *)tableName database:(NSString *)databaseName {
    
    // @"UPDATE '%@' SET %@ = '%@', %@ = '%@' WHERE db_pk_id = '%@';"
    
    // SQL语句
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE '%@' SET", tableName];
    
    // 属性个数
    unsigned int count = 0;
    // 属性列表
    objc_property_t *propertyList = class_copyPropertyList([model class], &count);
    
    // 拼接字段
    for (int i = 0; i < count; i++) {
        
        // 第i个属性
        objc_property_t property = propertyList[i];
        // 属性名
        const char *name = property_getName(property);
        // 属性对应数据库的字段名
        NSString *field = [NSString stringWithUTF8String:name];
        // 排除主键
        if ([field isEqualToString:kDatabasePrimaryKey]) {
            
            continue;
        }
        
        // 属性值对应数据库的字段值
        NSString *value = [model valueForKey:field];
        if (value) {
            
            // 拼接对应有值的字段
            sqlString = [sqlString stringByAppendingFormat:@" %@ = '%@',",field,value];
        }
    }
    
    // 释放
    free(propertyList);
    
    // 判断是否有需要更改的属性值
    if (count > 0) {
        
        // 移除最后一个字符串
        sqlString = [sqlString substringToIndex:(sqlString.length - 1)];
    } else {
        
        // 没有需要更改的属性值
        return nil;
    }
    
    // 数据库主键值
    NSString *primaryKey = [model valueForKey:kDatabasePrimaryKey];
    if (primaryKey) {
        
        // 拼接WHERE
        sqlString = [sqlString stringByAppendingFormat:@" WHERE db_pk_id = '%@'",primaryKey];
    }
    
    return [sqlString stringByAppendingString:@";"];
}

/// SQL语句-删除数据
/// @param query 条件
/// @param tableName 数据表名
- (NSString *)sql_deleteDataWith:(NSDictionary *)query inTable:(NSString *)tableName {
    
    // SQL语句
    __block NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE", tableName];
    
    if (query.count > 0) {
        
        [query enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            sqlString = [sqlString stringByAppendingFormat:@" %@ = '%@' AND", key, obj];
        }];
        
        // 删除最后的AND
        NSRange range = NSMakeRange(0, sqlString.length - 3);
        sqlString = [sqlString substringWithRange:range];
        return [sqlString stringByAppendingString:@";"];
    } else {
        
        // 删除所有数据
        return [NSString stringWithFormat:@"DELETE FROM '%@';", tableName];
    }
}

/// SQL语句-查询数据
/// @param query 条件
/// @param size 页大小
/// @param page 页码
/// @param tableName 数据表名
- (NSString *)sql_queryDataWith:(NSDictionary *)query size:(NSInteger)size page:(NSInteger)page inTable:(NSString *)tableName {
    
    // SQL语句
    __block NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE", tableName];
    
    if (query.count > 0) {
        
        [query enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            sqlString = [sqlString stringByAppendingFormat:@" %@ = '%@' AND", key, obj];
        }];
        
        // 删除最后的AND
        NSRange range = NSMakeRange(0, sqlString.length - 3);
        sqlString = [sqlString substringWithRange:range];
        return [sqlString stringByAppendingFormat:@"ORDER BY %@ DESC LIMIT %ld OFFSET (%ld);", kDatabasePrimaryKey,size, ((page-1) * size)];
    } else {
        
        // 查询所有数据
        return [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY %@ DESC LIMIT %ld OFFSET (%ld);", tableName, kDatabasePrimaryKey, size, ((page-1) * size)];
    }
}

/// SQL语句-模糊查询数据
/// @param query 条件
/// @param size 页大小
/// @param page 页码
/// @param tableName 数据表名
- (NSString *)sql_fuzzyQueryDataWith:(NSDictionary *)query size:(NSInteger)size page:(NSInteger)page inTable:(NSString *)tableName {
    
    // SQL语句
    __block NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE", tableName];
    
    if (query.count > 0) {
        
        [query enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            sqlString = [sqlString stringByAppendingFormat:@" %@ LIKE '%@' AND", key, obj];
        }];
        
        // 删除最后的AND
        NSRange range = NSMakeRange(0, sqlString.length - 3);
        sqlString = [sqlString substringWithRange:range];
        return [sqlString stringByAppendingFormat:@"ORDER BY %@ DESC LIMIT %ld OFFSET (%ld);", kDatabasePrimaryKey,size, ((page-1) * size)];
    } else {
        
        // 查询所有数据
        return [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY %@ DESC LIMIT %ld OFFSET (%ld);", tableName, kDatabasePrimaryKey, size, ((page-1) * size)];
    }
}

#pragma mark - private method

/// 是否是非空字符串
/// @param string 字符串
- (BOOL)isNonnullString:(NSString *)string {
    
    if (![string isKindOfClass:[NSString class]]) {
        
        return NO;
    }
    
    if ([string isEqualToString:@""]) {
        
        return NO;
    }
    
    return YES;
}

@end
