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

+ (PHCachingImageManager *)sharedAssetmanager {
    
    static PHCachingImageManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[PHCachingImageManager alloc] init];
    });
    
    return _sharedManager;
    
}


@end
