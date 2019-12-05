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
static NSString * const kDatabaseName = @"shop";
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
    
    // 根据模型创建数据表
    [self createDatabaseTable];
    
    // 插入模型数据
    int i = 5000;
    while (i) {

        [self insertModel];
        i--;
    }
    
    // 查询模型数据
    [self queryModel];
    
    // 删除模型数据
    [self deleteModel];
    
    // 清空数据表
//    [self truncateTable];
    
    // 删除数据表
//    [self dropTable];
    
    // 删除数据库文件
//    [self removeDatabase];
}


/// 创建数据库文件
- (void)createDatabase {
    
    // 默认路径创建数据库
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:kDatabaseName atPath:nil]) {
        
        NSLog(@"创建数据库文件-默认文件夹目录:成功!");
    } else {
        
        NSLog(@"创建数据库文件-默认文件夹目录:失败!");
    }
    
    NSLog(@"数据库文件路径:%@",[[GQHDatabaseManager qh_sharedDatabaseManager] qh_pathOfDatabase:kDatabaseName]);
    
    // 指定文件夹目录创建数据库文件
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *databasePath = [documentsPath stringByAppendingPathComponent:@"/db"];
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_createDatabase:kDatabaseName atPath:databasePath]) {
        
        NSLog(@"创建数据库文件-指定文件夹目录:成功!");
    } else {
        
        NSLog(@"创建数据库文件-指定文件夹目录:失败!");
    }
}

/// 根据model创建数据表
- (void)createDatabaseTable {
    
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_createTableInDatabase:kDatabaseName withTableName:kDatabaseTableProduct model:[GQHProductModel class]]) {
        
        NSLog(@"创建数据表: 成功!");
    } else {
        
        NSLog(@"创建数据表: 失败!");
    }
    
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_createTableInDatabase:kDatabaseName withTableName:kDatabaseTableOrder model:[GQHOrderModel class]]) {
        
        NSLog(@"创建数据表: 成功!");
    } else {
        
        NSLog(@"创建数据表: 失败!");
    }
}

/// 插入模型
- (void)insertModel {
    
    // 解决循环时内存暴涨
    @autoreleasepool {
        
        GQHProductModel *product = [[GQHProductModel alloc] init];
        product.qh_id = @"2019";
        product.qh_name = @"商品名称";
        product.qh_count = @(999);
        product.qh_price = @(34.00f);
        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:product inTable:kDatabaseTableProduct database:kDatabaseName];
        
        GQHOrderModel *order = [[GQHOrderModel alloc] init];
        order.qh_id = @"订单id";
        order.qh_name = @"订单收货人";
        order.qh_address = @"收货地址";
        order.qh_mobile = @"手机号";
        order.qh_count = @(6);
        order.qh_price = @(399.15f);
        order.qh_products = @[product];
        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:order inTable:kDatabaseTableOrder database:kDatabaseName];
        
        GQHOrderModel *another = [[GQHOrderModel alloc] init];
        another.qh_id = @"订单id";
        another.qh_name = @"订单收货人";
        another.qh_address = @"收货地址";
        another.qh_mobile = nil;
        another.qh_count = @(9);
        another.qh_price = @(399.15f);
        another.qh_products = @[product];
        [[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:another inTable:kDatabaseTableOrder database:kDatabaseName];
    }
}

/// 查询模型数据
- (void)queryModel {
    
    // 查询所有数据
    NSArray<GQHProductModel *> *products = [[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryAllWithClass:[GQHProductModel class] inTable:kDatabaseTableProduct database:kDatabaseName];
    NSLog(@"查询所有数据:%ld",products.count);
    
    // 查询指定条件
    NSArray<GQHOrderModel *> *orders = [[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryOneWithClass:[GQHOrderModel class] key:@"qh_count" value:@"6" inTable:kDatabaseTableOrder database:kDatabaseName];
    NSLog(@"查询指定条件:%@",orders);
}

/// 删除模型数据
- (void)deleteModel {
    
    [[GQHDatabaseManager qh_sharedDatabaseManager] qh_deleteDataWithKey:@"db_id_pk" value:@"2" inTable:kDatabaseTableProduct database:kDatabaseName];
}

/// 修改模型数据
- (void)updateModel {
    
    // 查询需要修改的模型数据
    NSArray<GQHOrderModel *> *orders = [[GQHDatabaseManager qh_sharedDatabaseManager] qh_queryOneWithClass:[GQHOrderModel class] key:@"db_id_pk" value:@"1" inTable:kDatabaseTableOrder database:kDatabaseName];
    
    for (GQHOrderModel *order in orders) {
        
        if (order) {
            
            // 修改数据
            order.qh_name = @"修改后的名称";
            // 插入数据
            if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_insertData:order inTable:kDatabaseTableOrder database:kDatabaseName]) {
                
                // 删除数据
                [[GQHDatabaseManager qh_sharedDatabaseManager] qh_deleteDataWithKey:@"db_id_pk" value:@"1" inTable:kDatabaseTableOrder database:kDatabaseName];
            }
        }
    }
}

/// 清空数据表
- (void)truncateTable {
    
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_truncateTable:kDatabaseTableProduct inDatabase:kDatabaseName]) {
        
        NSLog(@"清空数据表: 成功!");
    } else {
        
        NSLog(@"清空数据表: 失败!");
    }
}

/// 删除数据表
- (void)dropTable {
    
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_dropTable:kDatabaseTableProduct inDatabase:kDatabaseName]) {
        
        NSLog(@"删除数据表: 成功!");
    } else {
        
        NSLog(@"删除数据表: 失败!");
    }
}

/// 删除数据库文件-不能删除非空数据库
- (void)removeDatabase {
    
    // 清空数据表
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_truncateTable:kDatabaseTableOrder inDatabase:kDatabaseName]) {
        
        NSLog(@"清空数据表: 成功!");
    } else {
        
        NSLog(@"清空数据表: 失败!");
    }
    
    // 删除数据表
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_dropTable:kDatabaseTableOrder inDatabase:kDatabaseName]) {
        
        NSLog(@"删除数据表: 成功!");
    } else {
        
        NSLog(@"删除数据表: 失败!");
    }
    
    // 删除数据库
    if ([[GQHDatabaseManager qh_sharedDatabaseManager] qh_removeDatabase:kDatabaseName atPath:nil]) {

        NSLog(@"删除数据库:成功!");
    } else {

        NSLog(@"删除数据库:失败!");
    }
}

@end
