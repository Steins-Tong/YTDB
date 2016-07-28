//
//  DB.m
//  XMERP
//  此处代码移植自ThinkPHP 3.2.1 Db.class.php
//  Created by 佟阳 on 16/1/22.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "DB.h"

@implementation DB{
    NSString *insertSQL ;
    NSString *selectSQL ;
    NSString *updateSQL ;
    NSString *deleteSQL ;
}

-(instancetype)init{
    self = [super init];
    insertSQL = @"INSERT INTO %TABLE% (%KEYS%) VALUES (%VALUES%)";
    selectSQL = @"SELECT %DISTINCT% %FIELD% FROM %TABLE%%JOIN%%WHERE%%GROUP%%HAVING%%ORDER%%LIMIT% %UNION%%COMMENT%";
    deleteSQL = @"DELETE FROM %TABLE% %WHERE%";
    updateSQL = @"UPDATE %TABLE% SET %SET% %WHERE%";
    return self;
}


- (NSString*) parseTable:(id)tables{
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
    //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
    //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
    //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
    if([tables isKindOfClass:[NSDictionary class]]){

    }else if ([tables isKindOfClass:[NSString class]]){
        tables = [tables componentsSeparatedByString:@","];
        //array_walk($tables, array(&$this, 'parseKey'));

    }
    tables = [tables componentsJoinedByString:@","];
    return tables;
}

- (NSString*) parseUnion :(id)tunion{
    if ([tunion isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [tunion mutableCopy];
        NSString *str = @"";
        if ([dict objectForKey:@"_all"]) {
            str = @" UNION ALL ";
            [dict removeObjectForKey:@"_all"];
        }else{
            str = @" UNION ";
        }
        NSMutableArray *sqlArr = [NSMutableArray new];
        for (id item in dict) {
            //存在问题
            [sqlArr addObject:[NSString stringWithFormat:@" %@ ",item]];
        }
        return [sqlArr componentsJoinedByString:@" "];
    }else{
        return @"";
    }
}


- (NSString*) parseLimit:(NSString*) limit {
    return limit.length > 0 ? [NSString stringWithFormat:@" LIMIT %@ ",limit]:@"";
}

- (NSString*) parseOrder:(id) order {
    if ([order isKindOfClass:[NSArray class]] && [order count] > 0) {
        NSMutableArray *array = [NSMutableArray new];
        for (id dict in order) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                
                NSString *key = [dict allKeys][[dict count] - 1];
                NSString *value = [dict allValues][[dict count]- 1];
                [array addObject:[NSString stringWithFormat:@" %@ %@ ",key,value]];
                
            }else if([dict isKindOfClass:[NSString class]]){
                [array addObject:dict];
            }
            order = [array componentsJoinedByString:@","];
        }
    }

    return [order isKindOfClass:[NSString class]] && [order length] > 0 ? [NSString stringWithFormat:@" ORDER BY %@ ",order]:@"";
}

- (NSString*)parseGroup:(NSString*)group{
    return group.length > 0 ? [NSString stringWithFormat:@" GROUP BY %@ ",group]:@"";
}

- (NSString*)parseHaving:(NSString*)having{
    return having ? [NSString stringWithFormat:@" HAVING %@ ",having]:@"";
}

- (NSString*)parseComment:(NSString*)comment{
    return comment ? [NSString stringWithFormat:@"/* %@ */" ,comment]:@"";
}


- (NSString*) parseSet:(NSDictionary*)data PkField:(NSString*)pk{
    NSMutableArray *Values = [NSMutableArray new];
    NSArray *IgnoreField = [data objectForKey:@"_ignoreField"];
    for (int i=0; i<data.count; i++) {
        NSString *key = [data allKeys][i];
        NSString *value = [data allValues][i];
        
        BOOL isIgnore = IgnoreField == nil || [IgnoreField indexOfObject:[data allKeys][i]] ?
        
        [[data allKeys][i] isEqualToString:@"_ignoreField"] ? false : true
        
        : false;
        
        if (![key isEqualToString:pk] && isIgnore) {
            [Values addObject:[NSString stringWithFormat:@" %@ = \"%@\"",key,value]];
        }
    }
    return [Values componentsJoinedByString:@","];

}

- (NSString*) parseWhere:(id)where {
    NSString *whereStr = @"";
    
    if ([where isKindOfClass:[NSString class]]) {
        
        //直接使用字符串条件
        whereStr = where;
        
    }else if ([where isKindOfClass:[NSDictionary class]]){
        
        NSString *operate = [where objectForKey:@"_logic"] != nil ? [[where objectForKey:@"_logic"] uppercaseString] : @"";
        
        if ((int)[@[@"AND",@"OR",@"XOR"] indexOfObject:operate] > 0) {
            // 定义逻辑运算规则 例如 OR XOR AND NOT
            
            operate = [NSString stringWithFormat:@" %@ ",operate];
            
            [where removeObjectForKey:@"_logic"];
            
        }else{
            
            operate = @" AND ";
            
        }
        @autoreleasepool {
            
            for (int i=0; i<[where count]; i++) {
                
                NSString *key = [where allKeys][i];
                
                id val = [where allValues][i];
                
                if ([key isKindOfClass:[NSNumber class]]) {
                    
                    key = @"_complex";
                    
                }
                
                if ([key rangeOfString:@"_"].location != NSNotFound && [key rangeOfString:@"_"].location == 0) {
                    
                    whereStr = [whereStr stringByAppendingString:[self parseThinkWhereWithKey:key Value:val]];
                    
                }else{
                    
                    bool multi = [val isKindOfClass:[NSDictionary class]] && [val objectForKey:@"_multi"] != nil;
                    
                         key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    if ([key rangeOfString:@"|"].location != NSNotFound) {
                        
                        NSArray *array = [key componentsSeparatedByString:@"|"];
                        
                        NSMutableArray *str = [NSMutableArray new];
                        
                        for (int m = 0; m<array.count; m++) {
                            NSString *k = array[m];
                            NSString *v = multi ? val[m]:val;
                            [str addObject:[self parseWhereItemWithKey:k Value:v]];
                        }
                        
                        whereStr = [whereStr stringByAppendingString:[NSString stringWithFormat:@"( %@ )",[str componentsJoinedByString:@" OR "]]];
                        
                    }else if([key rangeOfString:@"&"].location != NSNotFound){
                        NSArray *array = [key componentsSeparatedByString:@"&"];
                        
                        NSMutableArray *str = [NSMutableArray new];
                        
                        for (int m = 0; m<array.count; m++) {
                            NSString *k = array[m];
                            NSString *v = multi ? val[m]:val;
                            [str addObject:[self parseWhereItemWithKey:k Value:v]];
                        }
                        
                        whereStr = [whereStr stringByAppendingString:[NSString stringWithFormat:@"( %@ )",[str componentsJoinedByString:@" and "]]];
                    
                    }else{
                        
                        whereStr = [whereStr stringByAppendingString:[self parseWhereItemWithKey:key Value:val]];
                        
                    }
                    
                }
                
                whereStr = [whereStr stringByAppendingString:operate];
            }
        }
        whereStr = [whereStr substringToIndex:whereStr.length - operate.length];
    }
    return whereStr.length > 0 ? [NSString stringWithFormat: @" WHERE %@",whereStr] :@"";
}





- (NSString*) parseWhereItemWithKey:(NSString*)key Value:(id) value {
    NSString *whereStr = @"";
    if ([value isKindOfClass:[NSArray class]]) {
        if ([value[0] isKindOfClass:[NSString class]]) {
            //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
            //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
            //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
            //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
            //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
            if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"/^(EQ|NEQ|GT|EGT|LT|ELT)$/i"] evaluateWithObject:value[0]]) {
                whereStr = [whereStr stringByAppendingString:[NSString stringWithFormat:@" %@  %@",[_comparison objectForKey:[value[0] lowercaseString]],value[1]]];
            }else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"/^(NOTLIKE|LIKE)$/i"] evaluateWithObject:value[0]]){
                
            }else if ([@"exp" isEqualToString:[value[0] lowercaseString]]){
                
            }else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"/IN/i"] evaluateWithObject:value[0]]){
                
            }else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"/BETWEEN/i"] evaluateWithObject:value[0]]){
                
            }else{
                //@throw
            }
        }else{
            //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
            //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
            //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
            //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
            //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
            NSInteger count = [value count];
            NSString *rule = value[count-1] ? [value[count-1] isKindOfClass:[NSArray class]] ? [value[count-1][0] uppercaseString] : [value[count-1] uppercaseString]:@"";
            
            if ([@[@"AND",@"OR",@"XOR"] indexOfObject:rule]) {
                count = count - 1;
            }else{
                rule = @"AND";
            }
            
            for (int i = 0 ; i < count ; i++) {
                NSString *data = [value[i] isKindOfClass:[NSArray class]] ? value[i][1] : value[i];
                if ([@"exp" isEqualToString:[value[i][0] lowercaseString]]) {
                    whereStr = [whereStr stringByAppendingString:[NSString stringWithFormat:@"%@ %@ %@ " ,key,data ,rule]];
                }else{
                    whereStr = [whereStr stringByAppendingString:[self parseWhereItemWithKey:key Value:[NSString stringWithFormat:@"%@ %@ ",value[i],rule]]];
                }
            }
            whereStr = [NSString stringWithFormat:@"( %@ )",[whereStr substringToIndex:-4]];
            
        }
    }else{
        whereStr = [whereStr stringByAppendingString:[NSString stringWithFormat:@" %@ = \"%@\" ",key,value]];
    }
    return whereStr;
}



- (NSString*) parseThinkWhereWithKey:(NSString*)key Value:(NSString*)value {
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
    //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
    //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
    //!!!!!!!!!!!!!!!!!!!!!注意以下代码未经测试!!!!!!!!!!!!!!!!!!!!!!!//
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
    NSString *whereStr   = @"";
    
    if([key isEqualToString:@"_string"]){
        // 字符串模式查询条件
        whereStr = value;
    }else if([key isEqualToString:@"_complex"]){
        // 复合查询条件
        
        whereStr = [value isKindOfClass:[NSString class]]  ? value : [value isKindOfClass:[NSNumber class]] ? [NSString stringWithFormat:@"%@",value] :
        [[self parseWhere:value] substringFromIndex:6];
    }else if([key isEqualToString:@"_query"]){
        // 字符串模式查询条件
        NSMutableDictionary *where = [[self parse_str:value] mutableCopy];
        NSString *op = @"";
        if ([where objectForKey:@"_logic"] != nil) {
            op = [NSString stringWithFormat:@" %@ ",[[where objectForKey:@"_logic"] uppercaseString]];
            [where removeObjectForKey:@"_logic"];
        }else{
            op = @" AND ";
        }
        NSMutableArray *array = [NSMutableArray new];
        for (id item in where) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = item;
                [array addObject:[NSString stringWithFormat:@"%@ = %@",[dict allKeys][dict.count - 1],[dict allValues][dict.count - 1]]];
            }
        }
        whereStr = [array componentsJoinedByString:op];
    }
    return [NSString stringWithFormat:@" ( %@ ) ",whereStr];
}

#pragma mark 解析字符串为字典
- (NSDictionary*)parse_str:(NSString*)str{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *strArray = [str componentsSeparatedByString:@"&"];
    for (NSString *itemStr in strArray) {
        NSArray *itemArray = [itemStr componentsSeparatedByString:@"="];
        if (itemArray.count == 2) {
            [dict setObject:itemArray[0] forKey:itemArray[1]];
        }
    }
    return dict;
}


#pragma mark  Join 分析
- (NSString*) parseJoin:(id)join {
    NSString *joinStr = @"";
    if (join != nil) {
        joinStr = [NSString stringWithFormat:@" %@ ",[join componentsJoinedByString:@" "]];
    }
    return joinStr;
}


#pragma mark  Field分析
- (NSString*) parseField:(id)fields {
    if ([fields isKindOfClass:[NSString class]] && [fields componentsSeparatedByString:@","] && [fields length] > 0) {
        fields = [fields componentsSeparatedByString:@","];
    }
    
    NSString *fieldStr = @"";
    
    if ([fields isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray new];
        for (int i=0;i<[fields count]; i++) {
            id val = fields[i];
            if([val isKindOfClass:[NSDictionary class]]){
                NSString *key = [val allKeys][[val count]-1];
                [array addObject:[NSString stringWithFormat:@"%@ AS %@",key,[val objectForKey:key]]];
            }else{
                [array addObject:val];
            }
        }
        fieldStr  = [array componentsJoinedByString:@","];
    }else if([fields isKindOfClass:[NSString class]] && fields != nil && [fields length] > 0){
        fieldStr = fields;
    }else{
        fieldStr = @"*";
    }
    return fieldStr;
}


- (NSDictionary*) parseData:(NSDictionary*)data{
    
    NSMutableArray *Values = [NSMutableArray new];
    
    NSMutableArray *Keys = [NSMutableArray new];
    
    NSArray *IgnoreField = [data objectForKey:@"_ignoreField"];
    
    for (int i = 0;i<data.count;i++) {
        
        BOOL isIgnore = IgnoreField == nil || [IgnoreField indexOfObject:[data allKeys][i]] ?
        
        [[data allKeys][i] isEqualToString:@"_ignoreField"] ? false : true
        
        : false;
        
        if ( isIgnore ) {
            
            [Keys addObject:[data allKeys][i]];
            
            [Values addObject:[NSString stringWithFormat:@"'%@'",[data allValues][i]]];
            
        }
        
    }
    
    return @{@"KEYS":[Keys componentsJoinedByString:@","],@"VALUES":[Values componentsJoinedByString:@","]};
}

#pragma -mark 解析SELECT语句
- (NSString*)parseSelectSqlWithOptions:(NSDictionary*)option{
    
    NSString *parseSql = [selectSQL stringByReplacingOccurrencesOfString:@"%TABLE%" withString:[option objectForKey:@"TABLE"]];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%DISTINCT%" withString:[option objectForKey:@"DISTINCT"] ?[option objectForKey:@"DISTINCT"] :@""];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%FIELD%" withString:[option objectForKey:@"FIELD"] ?[self parseField:[option objectForKey:@"FIELD"]] :@"*"];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%JOIN%" withString:[option objectForKey:@"JOIN"] ?[self parseJoin:[option objectForKey:@"JOIN"]] :@""];
    
    bool whereIsValid = ([[option objectForKey:@"WHERE"] isKindOfClass:[NSDictionary class]] && [[option objectForKey:@"WHERE"] count] > 0) || ([[option objectForKey:@"WHERE"] isKindOfClass:[NSString class]] && [[option objectForKey:@"WHERE"] length] > 0);
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%WHERE%" withString: whereIsValid ? [self parseWhere:[option objectForKey:@"WHERE"]]:@""];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%GROUP%" withString:[option objectForKey:@"GROUP"] ?[self parseGroup:[option objectForKey:@"GROUP"]] :@""];
    
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%HAVING%" withString:[option objectForKey:@"HAVING"] ? [self parseHaving:[option objectForKey:@"HAVING"]] :@""];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%ORDER%" withString:[option objectForKey:@"ORDER"] ? [self parseOrder:[option objectForKey:@"ORDER"]] :@""];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%LIMIT%" withString:[option objectForKey:@"LIMIT"] ?[self parseLimit:[option objectForKey:@"LIMIT"]] :@""];
    ;
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%UNION%" withString:[option objectForKey:@"UNION"] ? [self parseUnion:[option objectForKey:@"UNION"]]:@""];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%COMMENT%" withString:[option objectForKey:@"COMMENT"] ?[self parseComment:[option objectForKey:@"COMMENT"]] :@""];
    
    return parseSql;
}

#pragma -mark 解析UPDATE语句
- (NSString*)parseUpdateSqlWithOptions:(NSDictionary *)option{
    NSString *parseSql = [updateSQL stringByReplacingOccurrencesOfString:@"%TABLE%" withString:[option objectForKey:@"TABLE"]];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%SET%" withString:[self parseSet:[option objectForKey:@"SET"]PkField:[option objectForKey:@"PK"]]];
    
    bool whereIsValid = ([[option objectForKey:@"WHERE"] isKindOfClass:[NSDictionary class]] && [[option objectForKey:@"WHERE"] count] > 0) || ([[option objectForKey:@"WHERE"] isKindOfClass:[NSString class]] && [[option objectForKey:@"WHERE"] length] > 0);
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%WHERE%" withString: whereIsValid ? [self parseWhere:[option objectForKey:@"WHERE"]]:@""];
    
    return parseSql;
}

#pragma -mark 解析DELETE语句
- (NSString*)parseDeleteSqlWithOptions:(NSDictionary *)option{
    
    NSString *parseSql = [deleteSQL stringByReplacingOccurrencesOfString:@"%TABLE%" withString:[option objectForKey:@"TABLE"]];
    
    bool whereIsValid = ([[option objectForKey:@"WHERE"] isKindOfClass:[NSDictionary class]] && [[option objectForKey:@"WHERE"] count] > 0) || ([[option objectForKey:@"WHERE"] isKindOfClass:[NSString class]] && [[option objectForKey:@"WHERE"] length] > 0);
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%WHERE%" withString: whereIsValid ? [self parseWhere:[option objectForKey:@"WHERE"]]:@""];
    
    return parseSql;
}

#pragma -mark 解析INSERT语句
- (NSString*)parseInsertSqlWithOptions:(NSDictionary *)option{
    
    NSString *parseSql = [insertSQL stringByReplacingOccurrencesOfString:@"%TABLE%" withString:[option objectForKey:@"TABLE"]];
    
    NSDictionary *data = [self parseData:[option objectForKey:@"DATA"]];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%KEYS%" withString:[data objectForKey:@"KEYS"]];
    
    parseSql = [parseSql stringByReplacingOccurrencesOfString:@"%VALUES%" withString:[data objectForKey:@"VALUES"]];
    
    return parseSql;
}
@end
