//
//  YTDBDrive.h
//  XMERP
//
//  Created by 佟阳 on 16/1/21.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTDbUtil.h"



typedef enum {
    /*单条查询*/
    YTQueryByFind = 1,
    /*多条查询*/
    YTQueryBySelect

} DBQueryType;

@interface YTDBDrive : NSObject

-(instancetype)initWithByQueryType:(DBQueryType)type tableName:(NSString*)name;

#pragma -mark model相关数据存放
@property(nonatomic,strong) NSDictionary *modelData;


#pragma -mark 连贯操作需要的方法


-(YTDBDrive *(^)(NSString*))limit;

-(YTDBDrive *(^)(NSString*))group;
/*
 排序字段
 */
- (YTDBDrive *(^)(NSString*))order;

/*
 链接字段
 */
- (YTDBDrive *(^)(NSString*))join;

/*
 过滤字段
 */
- (YTDBDrive *(^)(NSDictionary*))where;

/*
 数据字段
 */
- (YTDBDrive *(^)(id model))data;

/*
 查询字段
 */
- (YTDBDrive *(^)(id))field;

/*
 查询一条
 */
- (id(^)(id))find;

/*
 查询一列
 */
- (NSArray *(^)(id))select;

/*
 添加方法
 */
- (BOOL (^)())add;

/*
 缓存方法
 */
- (BOOL (^)())cache;
/*
 更新方法
 */
- (BOOL (^)())save;

/*
 删除方法
 */
- (BOOL (^)())delete;

#pragma -mark 数据库队列
@property(nonatomic,strong,readonly) YTDbUtil *db;
#pragma -mark 查询类型
@property(nonatomic,assign,readonly) DBQueryType queryType;
#pragma -mark 要操作的数据表名
@property(nonatomic,strong) NSString *tableName;
#pragma -mark 查询的where条件
@property(nonatomic,strong,readonly) NSMutableDictionary *tableWhere;
#pragma -mark 查询的字段
@property(nonatomic,strong,readonly) id tableField;
#pragma -mark join字段
@property(nonatomic,strong,readonly) NSMutableArray<NSString*> *tableJoin;
#pragma -mark order字段
@property(nonatomic,strong,readonly) NSMutableArray<NSString*> *tableOrder;
#pragma -mark 数据库里存在的字段
@property(nonatomic,strong,readonly) NSDictionary *fieldName;
#pragma -mark 分页查询
@property(nonatomic,strong,readonly) NSString *tableLimit;
#pragma -mark 主键字段
@property(nonatomic,strong,readonly) NSString *pkField;
#pragma -mark 主键字段
@property(nonatomic,strong,readonly) NSString *groupField;

@end
