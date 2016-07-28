//
//  DB.h
//  XMERP
//
//  Created by 佟阳 on 16/1/22.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DB : NSObject


@property(nonatomic,strong) NSMutableDictionary *comparison;


- (NSString*)parseSelectSqlWithOptions:(NSDictionary*)option;
- (NSString*)parseInsertSqlWithOptions:(NSDictionary *)option;
- (NSString*)parseUpdateSqlWithOptions:(NSDictionary *)option;
- (NSString*)parseDeleteSqlWithOptions:(NSDictionary *)option;
@end
