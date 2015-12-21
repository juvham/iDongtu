//
//  GifAssetHelper.h
//  iDongtu
//
//  Created by 迅牛 on 15/11/12.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;
@interface GifAssetHelper : PHCachingImageManager

@property (nonatomic,strong) PHAssetCollection *assetCollection;
@property (nonatomic,strong ,readonly) PHImageRequestOptions *requestOption;

+(instancetype)sharedAssetHelper;

- (void)startCachingImagesForAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode;
- (void)stopCachingImagesForAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode;

@end
