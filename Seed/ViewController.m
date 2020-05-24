//
//  ViewController.m
//  Seed
//
//  Created by Mac on 2019/12/5.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import "ViewController.h"
#import "GQHDatabaseManager.h"
#import "GQHOrderModel.h"
#import "GQHProductModel.h"


/// 数据库名
static NSString * const kDatabaseName = @"shop.db";
/// 数据表名
static NSString * const kDatabaseTableOrder = @"order";
/// 数据表名
static NSString * const kDatabaseTableProduct = @"product";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //MARK: 数据库操作
    // 创建数据库文件(空库)
    [self createDatabase];
//
//    // 查询数据库文件路径
//    NSLog(@"%@",[[GQHDatabaseManager qh_sharedDatabaseManager] qh_filePathWithDatabaseName:kDatabaseName]);
//
//    // 删除数据库文件
//    [self removeDatabase];
//
//    //MARK: 数据表操作
//    // 创建表
//    [self createDatabaseTables];
//
//    // 查询表名
//    [self queryDatabaseTableNames];
//
//    // 清空表
//    [self truncateDatabase];
//
//    // 删除表
//    [self removeDatabaseTable];
//
    //MARK: CRUD操作
    // 插入模型数据
    for (NSInteger i = 0; i < 30; i++) {
        
//        [self insertData:i];
    }
    
    
    
    // 查询模型数据
    [self queryDate];
    
//    [self updateData];
    
    
//
//    // 删除模型数据
//    [self deleteData];
}

- (void)createDatabase {
    
    // 数据库结构体
    GQHDatabase database;
    // 默认Documents文件夹内
    database.db_path = nil;
    // 数据库文件名称
    database.db_name = kDatabaseName;
    // 数据表名称
    database.db_table = kDatabaseTableOrder;
    // 数据库密钥
    database.db_encrypt_key = nil;
    // 数据库对应的模型类
    database.db_cls = GQHOrderModel.class;
    
    // 创建数据库文件
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:database];
}

- (void)removeDatabase {
    
    // 数据库结构体
    GQHDatabase database;
    database.db_name = kDatabaseName;
    
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_removeDatabase:database];
}

- (void)createDatabaseTables {
    
    // 数据库结构体
    GQHDatabase database;
    // 数据库的名称
    database.db_name = kDatabaseName;
    // 数据库中数据表的名称-Order表
    database.db_table = kDatabaseTableOrder;
    // order表对应的模型类
    database.db_cls = [GQHOrderModel class];
    
    // 创建数据表
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:database];
    
    // Product表
    database.db_table = kDatabaseTableProduct;
    database.db_cls = [GQHProductModel class];
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:database];
}

- (void)queryDatabaseTableNames {
    
    // 数据库结构体
    GQHDatabase database;
    database.db_name = kDatabaseName;
    
    NSArray *tableNames = [[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryAllTableNamesInDatabase:database];
    NSLog(@"%@",tableNames);
}

- (void)truncateDatabase {
    
    // 数据库结构体
    GQHDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableProduct;
    
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_truncateDatabase:database];
}

- (void)removeDatabaseTable {
    
    // 数据库结构体
    GQHDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableProduct;
    
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_dropDatabase:database];
}

/// 插入模型
- (void)insertData:(NSInteger)count {
    
    // 解决循环时内存暴涨
    @autoreleasepool {
        
        // 数据库结构体
        GQHDatabase database;
        // 数据库文件名称
        database.db_name = kDatabaseName;
        // 数据表名称
        database.db_table = kDatabaseTableOrder;
        // 数据库密钥
        database.db_encrypt_key = nil;
        
        GQHOrderModel *order = [[GQHOrderModel alloc] init];
        order.qh_id = @"订单id";
        order.qh_name = @"订单收货人";
        order.qh_address = @"收货地址";
        order.qh_mobile = @"手机号";
        order.qh_count = @(count);
        order.qh_price = @(399.15f);
        [GQHDatabaseManager.qh_sharedDatabaseManager qh_insertData:order intoDatabase:database];
        
        
//
//
//        database.db_name = kDatabaseName;
//        database.db_table = kDatabaseTableProduct;
//
//        GQHProductModel *product = [[GQHProductModel alloc] init];
//        product.qh_id = @"2019";
//        product.qh_name = @"商品名称";
//        product.qh_count = @(999);
//        product.qh_price = @(34.00f);
//        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:product intoDatabase:database];
//
//
//        database.db_table = kDatabaseTableOrder;
//
//        order.qh_products = @[product];
//
//        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:order intoDatabase:database];
//
//        GQHOrderModel *another = [[GQHOrderModel alloc] init];
//        another.qh_id = @"订单id";
//        another.qh_name = @"订单收货人";
//        another.qh_address = @"收货地址";
//        another.qh_mobile = nil;
//        another.qh_count = @(9);
//        another.qh_price = @(399.15f);
//        another.qh_products = @[product];
//
//        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:another intoDatabase:database];
    }
}

- (void)queryDate {
    
    GQHDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    GQHSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6%"};
    condition.db_page = 1;
    condition.db_size = 100;
    
    NSLog(@"%@",[[GQHDatabaseManager qh_sharedDatabaseManager] qh_fuzzyQueryDataWith:condition]);
}

- (void)deleteData {
    
    GQHDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    GQHSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6"};
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_deleteDataWith:condition];
}

- (void)updateData {
    
    GQHDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    GQHSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6"};
    condition.db_page = 1;
    condition.db_size = 100;
    
    NSArray<GQHOrderModel *> *result = [[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryDataWith:condition];
    
    [result enumerateObjectsUsingBlock:^(GQHOrderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        GQHOrderModel *model = [[GQHOrderModel alloc] init];
        model.db_pk_id = obj.db_pk_id;
        model.qh_count = @(60);
        model.qh_price = @(299.99);
        [GQHDatabaseManager.qh_sharedDatabaseManager qh_updateData:model inDatabase:database];
    }];
}


@end
