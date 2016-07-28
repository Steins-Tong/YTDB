//
//  YTDbUtil.h
//  XMERP
//
//  Created by 佟阳 on 16/1/20.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface YTDbUtil : NSObject

@property(nonatomic,assign,readonly) sqlite3  *db;

@property(nonatomic,copy,readonly) NSString *databasePath;

@property(nonatomic,copy) NSString *dbName;

@property(nonatomic,strong) dispatch_queue_t concurrentDBQueue;

/*
 *执行更新SQL语句
 */
-(BOOL)execSql:(NSString*)sql;

/*
 *执行查询SQL语句返回字典或者数组
 */
-(id)querySql:(NSString*)sql;

+(YTDbUtil *)sharedInstance ;

@end

