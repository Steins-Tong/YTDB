//
//  YTDBDriveMark.m
//  XMERP
//
//  Created by 佟阳 on 16/1/21.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "YTDBDriveMaker.h"

@implementation YTDBDriveMaker

-(instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        //_db = [YTDbUtil sharedInstance];;
        
        _driveArray = [NSMutableArray new];
        
    }
    
    return self;
}

- (YTDBDrive *(^)(NSString*))M{
    
    return ^(NSString* tableName){
        
        if (tableName == nil) {
            
            tableName = _modelName;
            
        }
        
        YTDBDrive *drive = [[YTDBDrive alloc] initWithByQueryType:YTQueryByFind tableName:tableName];
        
        drive.modelData = _modelData;
        
        [_driveArray addObject:drive];
        
        return drive;
    };
}





@end
