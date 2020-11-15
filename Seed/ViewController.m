//
//  ViewController.m
//  Seed
//
//  Created by Mac on 2019/12/5.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import "ViewController.h"
#import "SeedDatabaseManager.h"
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
    
    
    
    
    
//# 功能清单
//
//### 数据库操作
//
//* 指定路径创建数据库文件
//* 根据数据库文件名获取文件路径
//* 删除数据库文件
//
//### 数据表操作
//
//* 根据数据模型创建数据表
//* 查询数据库所有数据表名称
//* 清空数据表
//* 删除数据表
//
//### CRUD操作
//
//* 插入模型数据
//* 修改模型数据
//* 条件查询
//* 模糊查询
//* 分页查询
//* 条件删除
//

    
    
    
//
//    // 查询数据库文件路径
//    NSLog(@"%@",[[SeedDatabaseManager s_sharedDatabaseManager] qh_filePathWithDatabaseName:kDatabaseName]);
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
//    [self queryDate];
    
//    [self updateData];
    
    
//
//    // 删除模型数据
//    [self deleteData];
}


#pragma mark ----------------------------- <数据库> -----------------------------

/// 创建数据库
- (void)createDatabase {
    
    // 数据库结构体
    SeedDatabase database;
    // 数据库绝对路径, 默认为Documents文件夹
    database.db_path = nil;
    // 数据库文件名称
    database.db_name = kDatabaseName;
    // 数据表名称
    database.db_table = kDatabaseTableOrder;
    // 数据库密钥, 默认为空表示不加密
    database.db_encrypt_key = nil;
    // 数据库对应的模型类
    database.db_cls = GQHOrderModel.class;
    
    // 创建数据库文件
    if ([[SeedDatabaseManager s_sharedDatabaseManager] s_createDatabase:database]) {
        NSLog(@"创建数据库成功");
    } else {
        NSLog(@"创建数据库失败");
    }
    
    // 数据库文件路径(Documents文件夹下, 已存在的数据库)
    NSLog(@"%@",[[SeedDatabaseManager s_sharedDatabaseManager] s_filePathWithDatabaseName:kDatabaseName]);
    
    // 删除数据库文件先清空表再删除表
    if ([[SeedDatabaseManager s_sharedDatabaseManager] s_dropDatabase:database]) {
        NSLog(@"删除数据表成功");
    } else {
        NSLog(@"删除数据表失败");
    }
    
    // 删除数据库文件
    if ([[SeedDatabaseManager s_sharedDatabaseManager] s_removeDatabase:database]) {
        NSLog(@"删除数据库成功");
    } else {
        NSLog(@"删除数据库失败");
    }
}

- (void)createDatabaseTables {
    
    // 数据库结构体
    SeedDatabase database;
    // 数据库的名称
    database.db_name = kDatabaseName;
    
    // 数据库中数据表的名称-Order表
    database.db_table = kDatabaseTableOrder;
    // order表对应的模型类
    database.db_cls = [GQHOrderModel class];
    
    // 创建数据表
    [[SeedDatabaseManager s_sharedDatabaseManager] s_createDatabase:database];
    
    // Product表
    database.db_table = kDatabaseTableProduct;
    database.db_cls = [GQHProductModel class];
    
    [[SeedDatabaseManager s_sharedDatabaseManager] s_createDatabase:database];
}

- (void)queryDatabaseTableNames {
    
    // 数据库结构体
    SeedDatabase database;
    database.db_name = kDatabaseName;
    
    NSArray *tableNames = [[SeedDatabaseManager s_sharedDatabaseManager] s_allTableNamesInDatabase:database];
    NSLog(@"%@",tableNames);
}

- (void)truncateDatabase {
    
    // 数据库结构体
    SeedDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableProduct;
    
    [[SeedDatabaseManager s_sharedDatabaseManager] s_truncateDatabase:database];
}

- (void)removeDatabaseTable {
    
    // 数据库结构体
    SeedDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableProduct;
    
    [[SeedDatabaseManager s_sharedDatabaseManager] s_dropDatabase:database];
}

/// 插入模型
- (void)insertData:(NSInteger)count {
    
    // 解决循环时内存暴涨
    @autoreleasepool {
        
        // 数据库结构体
        SeedDatabase database;
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
        [SeedDatabaseManager.s_sharedDatabaseManager s_insertData:order intoDatabase:database];
        
        
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
//        [[SeedDatabaseManager s_sharedDatabaseManager] qh_insertData:product intoDatabase:database];
//
//
//        database.db_table = kDatabaseTableOrder;
//
//        order.qh_products = @[product];
//
//        [[SeedDatabaseManager s_sharedDatabaseManager] qh_insertData:order intoDatabase:database];
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
//        [[SeedDatabaseManager s_sharedDatabaseManager] qh_insertData:another intoDatabase:database];
    }
}

- (void)queryDate {
    
    SeedDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    SeedSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6%"};
    condition.db_page = 1;
    condition.db_size = 100;
    
    NSLog(@"%@",[[SeedDatabaseManager s_sharedDatabaseManager] s_fuzzyQueryDataWith:condition]);
}

- (void)deleteData {
    
    SeedDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    SeedSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6"};
    [[SeedDatabaseManager s_sharedDatabaseManager] s_deleteDataWith:condition];
}

- (void)updateData {
    
    SeedDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    SeedSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6"};
    condition.db_page = 1;
    condition.db_size = 100;
    
    NSArray<GQHOrderModel *> *result = [[SeedDatabaseManager s_sharedDatabaseManager] s_queryDataWith:condition];
    
    [result enumerateObjectsUsingBlock:^(GQHOrderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        GQHOrderModel *model = [[GQHOrderModel alloc] init];
        model.db_pk_id = obj.db_pk_id;
        model.qh_count = @(60);
        model.qh_price = @(299.99);
        [SeedDatabaseManager.s_sharedDatabaseManager s_updateData:model inDatabase:database];
    }];
}

@end
