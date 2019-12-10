# 简介

基于[FMDB](https://github.com/ccgus/fmdb.git)的简单封装，实现数据模型与数据库的直接转换。支持数据库加密解密，支持iOS和macOS。

**主要功能**

* 根据数据模型创建数据表
* 数据模型直接插入数据表
* 数据表查询返回数据模型数组
* 支持分页查询

**待实现功能**

* 模糊查询

**注意事项**

* 非数据库基本类型均忽略不入库，保留字段，内容为空
* 数据表中除主键外，类型均为TEXT

# 功能清单

### 数据库操作

* 指定路径创建数据库文件
* 根据数据库文件名获取文件路径
* 删除数据库文件

### 数据表操作

* 根据数据模型创建数据表
* 查询数据库所有数据表名称
* 清空数据表
* 删除数据表

### CRUD操作

* 插入模型数据
* 条件查询
* 分页查询
* 条件删除

# 安装

### 1 导入FMDB

通过cocoapods导入FMDB，终端执行 pod insatll 命令

```
pod 'FMDB/SQLCipher'
```

### 2 添加SQLite依赖库

依次选择 TARGETS -> Build Phases -> Link Binary With Libraries ，添加 **libsqlite3.tbd**文件

### 3 添加文件

手动将 GQHDatabaseManager 文件夹拖入工程，在需要使用的类中引用头文件

```
#import "GQHDatabaseManager.h"
```


# 使用

默认对数据库不进行加密，需要加密，修改 **GQHDatabaseManager.m** 文件中的 **kDatabaseSecretKey** 值为非空，详细使用方法请下载。