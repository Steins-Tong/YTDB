//
//  NSObject+DB.m
//  XMERP
//
//  Created by 佟阳 on 16/1/20.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "NSObject+DB.h"
#import "MJExtension.h"
#import "YTDBDrive.h"

@implementation NSObject (DB)


- (void) yt_openDatabases:(void(^)(YTDBDriveMaker *Drive))block {
    
    YTDBDriveMaker *driveMark = [YTDBDriveMaker new];
    if ([self isKindOfClass:[NSObject class]]) {
        driveMark.modelData = [self mj_keyValues];
    }
    driveMark.modelName = NSStringFromClass([self class]);
    block(driveMark);
}

+ (id) yt_getDataBasesDataWithToModel:(void(^)(YTDBDriveMaker *Drive))block {
    
    YTDBDriveMaker *driveMark = [YTDBDriveMaker new];
    driveMark.modelName = NSStringFromClass([self class]);
    block(driveMark);
    if (driveMark.modelData != nil && [driveMark.modelData isKindOfClass:[NSDictionary class]]) {
        return [[self class] mj_objectWithKeyValues:driveMark.modelData];
    }else{
        return nil;
    }
}


+ (NSArray*) yt_getDataBasesDataWithToArray:(void(^)(YTDBDriveMaker *Drive))block{
    
    YTDBDriveMaker *driveMark = [YTDBDriveMaker new];
    driveMark.modelName = NSStringFromClass([self class]);
    block(driveMark);
    if (driveMark.modelData != nil && [driveMark.modelData isKindOfClass:[NSArray class]]) {
        Class someClass = NSClassFromString(driveMark.modelName);
        NSArray *modelArray = [someClass mj_objectArrayWithKeyValuesArray:driveMark.modelData];
        return modelArray;
    }else{
        return nil;
    }
}

- (NSString*)yt_toJson{
    NSString *jsonData = [self mj_JSONString];
    return jsonData;
}



/*
- (void)yt_readPropertieFromObjectToProperties:(NSMutableDictionary *)properties {
    
    unsigned int     propertyCount = 0;
    objc_property_t *propertyList  = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        const char *sPropName = property_getName(propertyList[i]);
        NSString *propName  = [NSString.alloc initWithFormat: @"%s", sPropName];
        [properties setObject:@"123" forKey:propName];
    }
    free(propertyList), propertyList = NULL;
}*/

@end
