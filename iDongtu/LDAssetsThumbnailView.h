
//  Created by AceElvis on 15/3/31.
//  Copyright (c) 2015年 GouMin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "GifAssetHelper.h"

IB_DESIGNABLE
@interface LDAssetsThumbnailView : UIView

@property (nonatomic, assign) PHFetchResult *assetsGroup;

@property (nonatomic, strong) IBInspectable UIImage *blankImage;

@end
