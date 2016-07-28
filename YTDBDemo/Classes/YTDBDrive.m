//
//  YTDBDrive.m
//  XMERP
//
//  Created by 佟阳 on 16/1/21.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "YTDBDrive.h"
#import "DB.h"
#import "MJExtension.h"
@implementation YTDBDrive{
    NSString *selectSql;
    int pkValue;
    DB *dbdrive;
}

-(instancetype)initWithByQueryType:(DBQueryType)type tableName:(NSString*)name{
    self = [super init];
    if (self) {
        _queryType = type;
        _tableName = name;
        dbdrive = [DB new];
        _tableWhere = [NSMutableDictionary new];
        _tableField = @"";
        _groupField = @"";
        _tableLimit = @"";
        _tableJoin = [NSMutableArray new];
        _tableOrder = [NSMutableArray new];
        _db = [YTDbUtil sharedInstance];
        _fieldName = [self yt_findTableField];
    }
    return self;
}


-(YTDBDrive *(^)(id))field{
    return ^(id fields){
        _tableField = fields;
        return self;
    };
}

-(YTDBDrive *(^)(NSString*))limit{
    return ^(id limit){
        _tableLimit = limit;
        return self;
    };
}

-(YTDBDrive *(^)(NSDictionary*))where{
    return ^(NSDictionary *whereData){
        _tableWhere = [whereData mutableCopy];
        return self;
    };
}

-(YTDBDrive *(^)(NSString*))join{
    return ^(NSString *joinStr){
        if ([joinStr isKindOfClass:[NSString class]]){
            [_tableJoin addObject:joinStr];
        }
        return self;
    };
}


-(YTDBDrive *(^)(NSString*))order{
    return ^(NSString *orderStr){
        if ([orderStr isKindOfClass:[NSString class]]){
            [_tableOrder addObject:orderStr];
        }
        return self;
    };
}

-(YTDBDrive *(^)(NSString*))group{
    return ^(NSString *groupStr){
        _groupField = groupStr;
        return self;
    };
}


- (YTDBDrive *(^)(id model))data{
    return ^(id model){
        if ([model isKindOfClass:[NSDictionary class]]) {
            _modelData = model;
        }else{
            _modelData = [model mj_keyValues];
        }
        return self;
    };
}



- (BOOL (^)())save {
    
    return ^(){
        
        if ([_modelData objectForKey:_pkField] == nil) return NO;
        
        if([_tableWhere isKindOfClass:[NSString class]] && ((NSString*)_tableWhere).length == 0){
            _tableWhere = [NSMutableDictionary new];
            [_tableWhere setObject:[_modelData objectForKey:_pkField] forKey:_pkField];
        }else if ([_tableWhere isKindOfClass:[NSDictionary class]]){
            if (![_tableWhere objectForKey:_pkField]) {
                [_tableWhere setObject:[_modelData objectForKey:_pkField] forKey:_pkField];
            }

        }
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        
        [options setObject:self.tableName forKey:@"TABLE"];
        [options setObject:self.tableWhere forKey:@"WHERE"];
        [options setObject:self.modelData forKey:@"SET"];
        [options setObject:self.pkField forKey:@"PK"];
        NSString *sql = [dbdrive parseUpdateSqlWithOptions:options];
        
        BOOL DbSaveReq = [_db execSql:sql];
        
       // DDLogDebug(@"数据保存:%@ 结果:%@",sql,@(DbSaveReq));
        
        return DbSaveReq;
    };
}


- (BOOL (^)())delete {
    return ^(){
        if (_tableWhere == nil) return NO;
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        
        [options setObject:self.tableName forKey:@"TABLE"];
        
        if ([_modelData objectForKey:_pkField] != nil){
            _tableWhere = [NSMutableDictionary new];
            [_tableWhere setObject:[_modelData objectForKey:_pkField] forKey:_pkField];
        }
        
        [options setObject:self.tableWhere forKey:@"WHERE"];
        
        NSString *sql = [dbdrive parseDeleteSqlWithOptions:options];
        
        BOOL DbSelectReq = [_db execSql:sql];
        
        //DDLogDebug(@"数据删除:%@ 结果:%@",sql,@(DbSelectReq));
        
        return DbSelectReq;

    };
}

- (BOOL (^)())cache{
    
    return ^(){
        
        if (!_modelData) return NO;
        if (![_modelData objectForKey:_pkField]) return NO;
        
        NSArray *model = self.where(@{_pkField:[_modelData objectForKey:_pkField]}).find(nil);
        if (model.count > 0) {
            return self.save();
        }else{
            return self.add();
        }
        
    };
    
}

/*
 执行添加方法
 */
- (BOOL (^)())add{
    
    return ^(){
        
        if (!_modelData) return NO;
        
        //[self yt_getPk];
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        
        [options setObject:self.tableName forKey:@"TABLE"];
        
        [options setObject:self.modelData forKey:@"DATA"];
        
        NSString *sql = [dbdrive parseInsertSqlWithOptions:options];
        
        BOOL DbSelectReq = [_db execSql:sql];
        
        NSLog(@"数据插入:%@ 新插入数",sql);
        
        return DbSelectReq;
    };

}

- (NSArray *(^)(id))select{
    return ^(NSString *find){
        NSMutableDictionary *options = [NSMutableDictionary new];
        [options setObject:self.tableName forKey:@"TABLE"];
        [options setObject:self.tableWhere forKey:@"WHERE"];
        [options setObject:self.tableJoin forKey:@"JOIN"];
        [options setObject:self.tableOrder forKey:@"ORDER"];
        [options setObject:self.tableField forKey:@"FIELD"];
        [options setObject:self.groupField forKey:@"GROUP"];
        [options setObject:self.tableLimit forKey:@"LIMIT"];
        return [self yt_getDatabasesData:options];
    };
}


/*
 执行查询单条数据方法
 */
- (id(^)(id))find{

    return ^(NSString *find){
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        
        [options setObject:self.tableName forKey:@"TABLE"];
        [options setObject:self.tableWhere forKey:@"WHERE"];
        [options setObject:self.tableJoin forKey:@"JOIN"];
        [options setObject:self.tableOrder forKey:@"ORDER"];
        [options setObject:self.tableField forKey:@"FIELD"];
        [options setObject:self.groupField forKey:@"GROUP"];
        [options setObject:@"1" forKey:@"LIMIT"];
        
        NSArray *req = [self yt_getDatabasesData:options];

        NSDictionary *reqDict = req.count > 0 ? req[0]:nil;
        
        return reqDict;

        
    };
}






- (int)yt_autoIncrement{
    
    if (_pkField == nil)  return 0;
    if (_tableName.length > 10) return 0;
    
    NSString *GetPkSQL  = @"SELECT MAX(%@) FROM %@";
    

    NSArray *rs = [_db querySql:[NSString stringWithFormat:GetPkSQL ,_pkField,_tableName]];
    
    for (NSDictionary *Item in rs) {
        if ([[Item objectForKey:_pkField] isKindOfClass:[NSString class]]) {
            pkValue = 0;
        }else{
            pkValue = (int)[Item objectForKey:_pkField];
        }

    }

    return pkValue;
    
}

- (NSArray*)yt_getDatabasesData:(NSDictionary*)options{

    
    NSString *sql = [dbdrive parseSelectSqlWithOptions:options];
    
NSLog(@"查询数据:%@",sql);
    
    id requst = [_db querySql:sql];
        
    return requst;
    
}

/*
 获取数据库里的字段
 */
- (NSDictionary*)yt_findTableField{
    
    #warning 如果是复合查询不查询主键
    if (_tableName.length > 20) return nil;
    
    NSMutableDictionary *fieldData = [NSMutableDictionary new];
    
    NSString *findFieldSQL = @"PRAGMA table_info(%@)";

    NSArray *rs = [_db querySql:[NSString stringWithFormat:findFieldSQL,_tableName]];
    
    for(NSDictionary *Item in rs) {
        
        [fieldData setObject:[Item objectForKey:@"type"] forKey:[Item objectForKey:@"name"]];
        
        if ([[Item objectForKey:@"pk"] isEqualToNumber:@(1)]) {
            
            _pkField = [Item objectForKey:@"name"];
            
        }
        
    }
    
    return fieldData;
    
}

@end
