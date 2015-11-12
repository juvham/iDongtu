//
//  GifAssetHelper.h
//  iDongtu
//
//  Created by 迅牛 on 15/11/12.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;
@interface GifAssetHelper : NSObject

@property (nonatomic,strong) PHAssetCollection *assetCollection;

+(instancetype)sharedAssetHelper;

@end
