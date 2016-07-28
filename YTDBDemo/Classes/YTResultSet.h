//
//  YTResultSet.h
//  XMERP
//
//  Created by 佟阳 on 16/7/26.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface YTResultSet : NSObject

@property(nonatomic,assign,readonly) sqlite3_stmt *statement;

@property(nonatomic,assign,readonly) sqlite3 *parentDB;

- (instancetype)initWithStmt:(sqlite3_stmt*)stmt;

-(id)getObjectArray;

@end
