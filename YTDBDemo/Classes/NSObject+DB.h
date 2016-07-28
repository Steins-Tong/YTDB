//
//  NSObject+DB.h
//  XMERP
//
//  Created by 佟阳 on 16/1/20.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTDbUtil.h"
#import "YTDBDriveMaker.h"
@interface NSObject (DB)


/**
 *  打开数据库操作
 *  @param block 传入代码块
 *  @return void
 */
- (void) yt_openDatabases:(void(^)(YTDBDriveMaker *Drive))block;


/**
 *  获取数据库数据并得到Model
 *  @param block 传入代码块
 *  @return Model实例
 */
+ (id) yt_getDataBasesDataWithToModel:(void(^)(YTDBDriveMaker *Drive))block;


/**
 *  获取数据库数据并得到ModelArray
 *  @param block 传入代码块
 *  @return Model数组
 */
+ (NSArray*) yt_getDataBasesDataWithToArray:(void(^)(YTDBDriveMaker *Drive))block;


/**
 *  获得JSON字符串
 */
- (NSString*)yt_toJson;
@end
