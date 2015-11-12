//
//  GifAssetHelper.m
//  iDongtu
//
//  Created by 迅牛 on 15/11/12.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import "GifAssetHelper.h"

@implementation GifAssetHelper

+ (instancetype)sharedAssetHelper {
    static GifAssetHelper *_sharedHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedHelper = [[GifAssetHelper alloc] init];
    });
    
    return _sharedHelper;
}


@end
