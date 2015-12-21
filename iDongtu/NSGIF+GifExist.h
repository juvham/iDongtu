//
//  NSGIF+GifExist.h
//  iDongtu
//
//  Created by 迅牛 on 15/11/11.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <Foundation/Foundation.h>
#define gifFileDirectory   @"/Documents/GIF"
@interface NSFileManager (GifExist)

+ (BOOL)gifExistWithGIFURL:(NSURL *)gifUrl;
+ (BOOL)gifExistWithURL:(NSURL *)url;
+ (NSURL *)gifURLWithURL:(NSURL *)url;

@end
