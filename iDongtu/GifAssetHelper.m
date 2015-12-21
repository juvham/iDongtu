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
        _sharedHelper -> _requestOption = [[PHImageRequestOptions alloc] init];
//        _sharedHelper -> _requestOption.resizeMode = PHImageRequestOptionsResizeModeExact;
        _sharedHelper -> _requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        _sharedHelper -> _requestOption.networkAccessAllowed = YES;
        
    });
    
    return _sharedHelper;
}

- (void)startCachingImagesForAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode {
    
    [self startCachingImagesForAssets:assets targetSize:targetSize contentMode:contentMode options:self.requestOption];
}

- (void)stopCachingImagesForAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode {
    
    [self stopCachingImagesForAssets:assets targetSize:targetSize contentMode:contentMode options:self.requestOption];
}


@end;
