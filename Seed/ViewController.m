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

    // Do any additional setup after loading the view.
    
    // 创建数据库文件
    [self createDatabase];
    
    // 插入模型数据
    [self insertModel];
    
    // 查询模型数据
    [self queryDate];
    
    // 删除模型数据
//    [self deleteModel];
    
    // 清空数据表
//    [self truncateTable];
    
    // 删除数据表
//    [self dropTable];
    
    // 删除数据库文件
//    [self removeDatabase];
}

/// 创建数据库文件
- (void)createDatabase {
    
    GQHDatabase database;
    database.db_name = kDatabaseName;
    
    // order
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:database];
    
    // product
    database.db_table = kDatabaseTableProduct;
    database.db_cls = [GQHProductModel class];
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:database];
    
    NSLog(@"%@",[[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryAllTableNamesInDatabase:database]);
    
    
    // 删除数据库
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_removeDatabase:database];
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_dropDatabase:database];
}

/// 插入模型
- (void)insertModel {
    
    // 解决循环时内存暴涨
    @autoreleasepool {
        
        GQHDatabase database;
        database.db_name = kDatabaseName;
        database.db_table = kDatabaseTableProduct;
        
        GQHProductModel *product = [[GQHProductModel alloc] init];
        product.qh_id = @"2019";
        product.qh_name = @"商品名称";
        product.qh_count = @(999);
        product.qh_price = @(34.00f);
        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:product intoDatabase:database];
        
        
        database.db_table = kDatabaseTableOrder;
        
        GQHOrderModel *order = [[GQHOrderModel alloc] init];
        order.qh_id = @"订单id";
        order.qh_name = @"订单收货人";
        order.qh_address = @"收货地址";
        order.qh_mobile = @"手机号";
        order.qh_count = @(6);
        order.qh_price = @(399.15f);
        order.qh_products = @[product];
        
        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:order intoDatabase:database];
        
        GQHOrderModel *another = [[GQHOrderModel alloc] init];
        another.qh_id = @"订单id";
        another.qh_name = @"订单收货人";
        another.qh_address = @"收货地址";
        another.qh_mobile = nil;
        another.qh_count = @(9);
        another.qh_price = @(399.15f);
        another.qh_products = @[product];
        
        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:another intoDatabase:database];
    }
}

- (void)queryDate {
    
    GQHDatabase database;
    database.db_name = kDatabaseName;
    database.db_table = kDatabaseTableOrder;
    database.db_cls = [GQHOrderModel class];
    
    GQHSQLiteCondition condition;
    condition.db_database = database;
    condition.db_query = @{@"qh_count":@"6"};
    condition.db_page = 2;
    condition.db_size = 5;
    
    NSLog(@"%@",[[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryDataWith:condition]);
}

@end
