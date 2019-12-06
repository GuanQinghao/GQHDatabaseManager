//
//  GQHOrderModel.h
//  Seed
//
//  Created by Mac on 2019/12/5.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GQHProductModel;


NS_ASSUME_NONNULL_BEGIN

@interface GQHOrderModel : NSObject

/**
 SQLite数据表的主键(固定)
 */
@property (nonatomic, strong) NSNumber *db_pk_id;

/**
 后台业务id
 */
@property (nonatomic, copy) NSString *qh_id;

/**
 <#Description#>
 */
@property (nonatomic, copy) NSString *qh_name;

/**
 <#Description#>
 */
@property (nonatomic, copy) NSString *qh_address;

/**
 <#Description#>
 */
@property (nonatomic, copy) NSString *qh_mobile;

/**
 <#Description#>
 */
@property (nonatomic, strong) NSNumber *qh_count;

/**
 <#Description#>
 */
@property (nonatomic, strong) NSNumber *qh_price;

/**
 <#Description#>
 */
@property (nonatomic, strong) NSArray<GQHProductModel *> *qh_products;

@end

NS_ASSUME_NONNULL_END
