//
//  FileManager.m
//  XMERP
//
//  Created by 佟阳 on 16/2/19.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager


- (BOOL)copyDBFileToCaches:(NSString*)fileName {
    
    //@"Contacts"
    //文件类型
    NSString * docPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"db"];
    
    // 沙盒Library目录
    NSString * appDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    //appLib  Library/Caches目录
    NSString *appLib = [appDir stringByAppendingString:@"/Caches"];
    
    BOOL filesPresent = [self copyMissingFile:docPath toPath:appLib];
    
    return filesPresent;
}

- (BOOL)checkFileIsExist:(NSString*)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:path]){
        return false;
    }else{
        return true;
    }
}


/**
 *    @brief    把Resource文件夹下的save1.dat拷贝到沙盒
 *
 *    @param     sourcePath     Resource文件路径
 *    @param     toPath     把文件拷贝到XXX文件夹
 *
 *    @return    BOOL
 */
- (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath {
    BOOL retVal = YES; // If the file already exists, we'll return success…
    NSString * finalLocation = [toPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalLocation])
    {
        retVal = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:finalLocation error:NULL];
    }
    return retVal;
}


/**
 *    @brief    创建文件夹
 *
 *    @param     createDir     创建文件夹路径
 */
- (void)createFolder:(NSString *)createDir {
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
@end
