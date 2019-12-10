//
//  GQHEncryptDatabase.m
//  Seed
//
//  Created by Mac on 2019/12/10.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import "GQHEncryptDatabase.h"
#import <sqlite3.h>


@interface GQHEncryptDatabase () {
    
    // 密钥
    NSString *_encryptKey;
}

@end

@implementation GQHEncryptDatabase

/// 创建加密数据库
/// @param aPath 数据库路径
/// @param encryptKey 密钥
+ (instancetype)databaseWithPath:(NSString *)aPath encryptKey:(NSString *)encryptKey {
    
    return [[[self class] alloc] initWithPath:aPath encryptKey:encryptKey];
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

#pragma mark - Override

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
