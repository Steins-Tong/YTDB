//
//  YTDBDriveMark.h
//  XMERP
//
//  Created by 佟阳 on 16/1/21.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YTDBDrive.h"

@interface YTDBDriveMaker : NSObject

@property(nonatomic,strong) NSMutableArray<YTDBDrive*> *driveArray;

@property(nonatomic,strong) id modelData;

@property(nonatomic,strong) NSString *modelName;

-(YTDBDrive *(^)(NSString*))M;

@end
