//
//  YTResultSet.m
//  XMERP
//
//  Created by 佟阳 on 16/7/26.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "YTResultSet.h"

@implementation YTResultSet

- (instancetype)initWithStmt:(sqlite3_stmt*)stmt {
    
    self = [super init];
    
    if (self) {
    
        _statement = stmt;
        
    }
    
    return self;
    
}

-(id)getObjectArray{

    NSMutableArray *DataArray = [NSMutableArray new];
    
    while (sqlite3_step(_statement) == SQLITE_ROW) {

        NSDictionary *Data = [self resultDictionary];
        
        [DataArray addObject:Data];
        
    }

    return [DataArray copy];
    
}


- (NSDictionary*)resultDictionary{
    
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count(_statement);
    
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
        int columnCount = sqlite3_column_count(_statement);
        
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(_statement, columnIdx)];
            id objectValue = [self objectForColumnIndex:columnIdx];
            [dict setObject:objectValue forKey:columnName];
        }
        
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    
    return nil;
}

- (id)objectForColumnIndex:(int)columnIdx {
    int columnType = sqlite3_column_type(_statement, columnIdx);
    
    id returnValue = nil;
    
    if (columnType == SQLITE_INTEGER) {
        returnValue = [NSNumber numberWithLongLong:[self longLongIntForColumnIndex:columnIdx]];
    }
    else if (columnType == SQLITE_FLOAT) {
        returnValue = [NSNumber numberWithDouble:[self doubleForColumnIndex:columnIdx]];
    }
    else if (columnType == SQLITE_BLOB) {
        returnValue = [self dataForColumnIndex:columnIdx];
    }
    else {
        //default to a string for everything else
        returnValue = [self stringForColumnIndex:columnIdx];
    }
    
    if (returnValue == nil) {
        returnValue = [NSNull null];
    }
    
    return returnValue;
}

- (NSData*)dataForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_statement, columnIdx) == SQLITE_NULL || (columnIdx < 0)) {
        return nil;
    }
    
    const char *dataBuffer = sqlite3_column_blob(_statement, columnIdx);
    int dataSize = sqlite3_column_bytes(_statement, columnIdx);
    
    if (dataBuffer == NULL) {
        return nil;
    }
    
    return [NSData dataWithBytes:(const void *)dataBuffer length:(NSUInteger)dataSize];
}

- (double)doubleForColumnIndex:(int)columnIdx {
    return sqlite3_column_double(_statement, columnIdx);
}

- (long long int)longLongIntForColumnIndex:(int)columnIdx {
    return sqlite3_column_int64(_statement, columnIdx);
}

- (NSString*)stringForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_statement, columnIdx) == SQLITE_NULL || (columnIdx < 0)) {
        return nil;
    }
    
    const char *c = (const char *)sqlite3_column_text(_statement, columnIdx);
    
    if (!c) {
        // null row.
        return nil;
    }
    
    return [NSString stringWithUTF8String:c];
}

@end
