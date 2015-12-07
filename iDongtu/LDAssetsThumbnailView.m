
//  Created by AceElvis on 15/3/31.
//  Copyright (c) 2015年 GouMin. All rights reserved.
//

#import "LDAssetsThumbnailView.h"

@interface LDAssetsThumbnailView ()

@property (nonatomic, strong) NSArray *thumbnailImages;

@end

@implementation LDAssetsThumbnailView
@synthesize blankImage = _blankImage;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor =  [UIColor clearColor];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(74.0, 74.0);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    if (self.thumbnailImages.count == 3) {
        UIImage *thumbnailImage = self.thumbnailImages[2];
        
        CGRect thumbnailImageRect = CGRectMake(rect.origin.x + 4, rect.origin.y, rect.size.width -8, rect.size.height - 8);
        
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    if (self.thumbnailImages.count >= 2) {
        UIImage *thumbnailImage = self.thumbnailImages[1];
        
        CGRect thumbnailImageRect = CGRectMake(rect.origin.x + 2, rect.origin.y + 2, rect.size.width - 4, rect.size.height - 4);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    if (self.thumbnailImages.count >= 1) {
        UIImage *thumbnailImage = self.thumbnailImages[0];
        
        CGRect thumbnailImageRect = CGRectMake(rect.origin.x , rect.origin.y + 4, rect.size.width, rect.size.height);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
}


#pragma mark - setter/getter
- (void)setAssetsGroup:(PHFetchResult *)assetsGroup
{
    if (_assetsGroup != assetsGroup) {
        _assetsGroup = assetsGroup;
        // Extract three thumbnail images
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(3, assetsGroup.count))];
        
        // Prepare group for firing completion block
        dispatch_group_t imageQueue = dispatch_group_create();
        
        NSArray *array = [assetsGroup objectsAtIndexes:indexes];
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        [[GifAssetHelper sharedAssetmanager] startCachingImagesForAssets:array targetSize:CGSizeMake(100, 100) contentMode:(PHImageContentModeAspectFit) options:option];
        
        NSMutableArray *thumbnailImages = [NSMutableArray array];
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            dispatch_group_enter(imageQueue);
            PHAsset *asset = (PHAsset *)obj;
            
            [[GifAssetHelper sharedAssetmanager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                [thumbnailImages addObject:result];
                dispatch_group_leave(imageQueue);
            }];
        }];
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_group_notify(imageQueue, dispatch_get_main_queue(), ^{
            // Return GIF URL
            
            while ([thumbnailImages count] < 3) {
                
                [thumbnailImages addObject:weakSelf.blankImage];
            }
            weakSelf.thumbnailImages = thumbnailImages;
            [weakSelf setNeedsDisplay];
        });
    }
}

- (void)setBlankImage:(UIImage *)blankImage {
    
    _blankImage = [blankImage copy];
    
    [self setNeedsDisplay];
}

- (UIImage *)blankImage {
    
    if (_blankImage == nil) {
        
        _blankImage = [UIImage imageNamed:@"ico"];
    }
    
    return _blankImage;
}


@end
