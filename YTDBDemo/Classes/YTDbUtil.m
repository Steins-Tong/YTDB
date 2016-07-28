//
//  YTDbUtil.m
//  XMERP
//
//  Created by 佟阳 on 16/1/20.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "YTDbUtil.h"
#import "YTResultSet.h"
@implementation YTDbUtil{
    
   NSLock *lock;
    
}

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        
        NSString * appDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        
        //appLib  Library/Caches目录
        NSString *documentDirectory = [appDir stringByAppendingString:@"/Caches"];
        
        _dbName = @"Contacts.db";
        
        _databasePath = [documentDirectory stringByAppendingPathComponent:_dbName];

        
        
    }
    
    return self;
}

- (const char*)sqlitePath {
    
    if (!_databasePath) {
        return ":memory:";
    }
    
    if ([_databasePath length] == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    
    return [_databasePath fileSystemRepresentation];
    
}

- (BOOL)open {
    
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open([self sqlitePath], &_db );
    
    if(err != SQLITE_OK) {
        
        NSLog(@"YTDB:数据库打开异常!: %d", err);
        
        return NO;
        
    }
    
    return YES;
    
}

- (BOOL)close {
    
    if (!_db) {
        return YES;
    }
    
    int  rc;
    
    BOOL retry;
    
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry   = NO;
        rc      = sqlite3_close(_db);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0) {
                    NSLog(@"YTDB:关闭泄露的链接");
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            NSLog(@"YTDB:关闭异常!: %d", rc);
        }
    }
    while (retry);
    
    _db = nil;
    return YES;
}

/*
 *过滤多余的\
 */
- (NSString*)parseField:(NSString*)field {
    
    return [field stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
}


- (BOOL) execSql:(NSString*)sql {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(self.concurrentDBQueue, ^{
        
        [weakSelf open];
        
    });
    
    sqlite3_stmt *statement;
    
    int success2 = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &statement, NULL);
    
    if (success2 != SQLITE_OK) {
        
        NSLog(@"YTDB:插入数据库预处理异常!");
        
        [self close];
        
        return NO;
    }
    
    //执行插入语句
    success2 = sqlite3_step(statement);
    //释放statement
    sqlite3_finalize(statement);
    
    //如果插入失败
    if (success2 == SQLITE_ERROR) {
        NSLog(@"YTDB:插入数据库异常!");
        //关闭数据库
        [self close];
        return NO;
    }
    
    dispatch_sync(self.concurrentDBQueue, ^{
        
        [weakSelf close];
        
    });
    
    return YES;
}

- (id) querySql:(NSString*)sql {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(self.concurrentDBQueue, ^{
        
        [weakSelf open];
        
    });
    
    NSArray *ResultData ;
    
    sqlite3_stmt *statement = nil;
    
    if (sqlite3_prepare_v2(_db, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        
        NSLog(@"YTDB:数据库查询失败!");
        
        [self close];
        
        return nil;
        
    }else{
    
        YTResultSet *Result = [[YTResultSet alloc] initWithStmt:statement];
        
        ResultData = [Result getObjectArray];
        
    }
    
    dispatch_sync(self.concurrentDBQueue, ^{
        
        [weakSelf close];
        
    });
    
    return ResultData;
}


+ (YTDbUtil *) sharedInstance {
    
    static YTDbUtil *instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[YTDbUtil alloc] init];
        
        instance->_concurrentDBQueue = dispatch_queue_create("com.xiangmaikeji.DBQueue",DISPATCH_QUEUE_CONCURRENT);
        
    });
    
    return instance;
}

@end
