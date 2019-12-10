//
//  GQHEncryptDatabaseQueue.m
//  Seed
//
//  Created by Mac on 2019/12/10.
//  Copyright © 2019 GuanQinghao. All rights reserved.
//

#import "GQHEncryptDatabaseQueue.h"
#import "GQHEncryptDatabase.h"

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif


static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

@interface GQHEncryptDatabaseQueue () {
    
    // 队列
    dispatch_queue_t _queue;
    // 数据库
    FMDatabase *_db;
    // 密钥
    NSString *_encryptKey;
}

@end

@implementation GQHEncryptDatabaseQueue

@synthesize path = _path;
@synthesize openFlags = _openFlags;

/// 加密数据库队列
/// @param aPath 数据库路径
/// @param encryptKey 密钥
+ (instancetype)databaseQueueWithPath:(NSString *)aPath encryptKey:(NSString *)encryptKey {
    
    GQHEncryptDatabaseQueue *queue = [[self alloc] initWithPath:aPath encryptKey:encryptKey];
    
    FMDBAutorelease(queue);
    
    return queue;
}

- (instancetype)initWithPath:(NSString *)aPath encryptKey:(NSString *)encryptKey {
    
    return [self initWithPath:aPath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE vfs:nil encryptKey:encryptKey];
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags vfs:(NSString *)vfsName encryptKey:(NSString *)encryptKey {
    
    if (self == [super init]) {
        
        _encryptKey = encryptKey;
        
        _db = [[[self class] databaseClass] databaseWithPath:aPath encryptKey:encryptKey];
        
        FMDBRetain(_db);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:openFlags vfs:vfsName];
#else
        BOOL success = [_db open];
#endif
        
        if (!success) {
            
            NSLog(@"Could not create database queue for path %@", aPath);
            
            FMDBRelease(self);
            
            return 0x00;
        }
        
        _path = FMDBReturnRetained(aPath);
        
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
        
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        
        _openFlags = openFlags;
    }
    
    return self;
}

#pragma mark - Override

+ (Class)databaseClass {
    
    return [GQHEncryptDatabase class];
}

- (FMDatabase*)database {
    
    if (!_db) {
        
        _db = FMDBReturnRetained([[[self class] databaseClass] databaseWithPath:_path encryptKey:_encryptKey]);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:_openFlags];
#else
        BOOL success = [_db open];
#endif
        
        if (!success) {
            
            NSLog(@"FMDatabaseQueue could not reopen database for path %@", _path);
            
            FMDBRelease(_db);
            
            _db  = 0x00;
            
            return 0x00;
        }
    }
    
    return _db;
}

@end
