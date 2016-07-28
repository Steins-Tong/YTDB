//
//  FileManager.h
//  XMERP
//
//  Created by 佟阳 on 16/2/19.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

- (BOOL)copyDBFileToCaches:(NSString*)fileName;
- (BOOL)checkFileIsExist:(NSString*)path;
@end
