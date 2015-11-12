//
//  NSGIF+GifExist.m
//  iDongtu
//
//  Created by 迅牛 on 15/11/11.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import "NSGIF+GifExist.h"

@implementation NSFileManager (GifExist)

+ (BOOL)gifExistWithURL:(NSURL *)url {
    
    NSURL *gifUrl = [self gifURLWithURL:url];
    
    BOOL isDirectory;
    BOOL isExist = NO;
    
    NSString *filePath = [gifUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        

        
    } else {
    
        if (!isDirectory) {
            
            isExist = YES;
        }
    }

    return isExist;

}
+ (BOOL)gifExistWithGIFURL:(NSURL *)gifUrl {
     
    BOOL isDirectory;
    BOOL isExist = NO;
    // 判断文件夹是否存在，如果不存在，则创建

    
    NSString *filePath = [gifUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
  
    } else {
        
        isExist = YES;
    }
    
    return isExist;
}

+ (NSURL *)gifURLWithURL:(NSURL *)url {
    
    NSString *filePath = NSHomeDirectory();
    
    filePath = [filePath stringByAppendingString:gifFileDirectory];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSArray *realURL = [url pathComponents];
    /*!
     *  @author juvham
     *
     *  @brief  取出最后三级
     */
    for (int i = 3; i > 0; i--) {
        fileURL = [fileURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",[realURL objectAtIndex:realURL.count -i]]];
    }
    //替换成gif
    fileURL = [fileURL URLByDeletingPathExtension];
    fileURL = [fileURL URLByAppendingPathExtension:@"gif"];
    
    return fileURL;
}

@end
