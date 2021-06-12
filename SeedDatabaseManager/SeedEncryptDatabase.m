//
//  SeedEncryptDatabase.m
//  Seed
//
//  Created by Hao on 2020/11/15.
//  Copyright © 2020 GuanQinghao. All rights reserved.
//

#import "SeedEncryptDatabase.h"
#import <sqlite3.h>


@interface SeedEncryptDatabase () {
    
    // 密钥
    NSString *_encryptKey;
}

@end

@implementation SeedEncryptDatabase

/// 创建加密数据库
/// @param aPath 数据库路径
/// @param encryptKey 密钥
+ (instancetype)databaseWithPath:(NSString *)aPath encryptKey:(NSString *)encryptKey {
    
    return [[self alloc] initWithPath:aPath encryptKey:encryptKey];
}

/// 创建加密数据库
/// @param aPath 数据库路径
/// @param encryptKey 密钥
- (instancetype)initWithPath:(NSString *)aPath encryptKey:(NSString *)encryptKey {
    
    if (self = [self initWithPath:aPath]) {
        
        _encryptKey = encryptKey;
    }
    
    return self;
}

#pragma mark - override

- (BOOL)open {
    
    BOOL result = [super open];
    
    if (result && _encryptKey) {
        
        [self setKey:_encryptKey];
    }
    
    return result;
}

#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags vfs:(NSString *)vfsName {
    
    BOOL result = [super openWithFlags:flags vfs:vfsName];
    
    if (result && _encryptKey) {
        
        [self setKey:_encryptKey];
    }
    
    return result;
}
#endif

@end
