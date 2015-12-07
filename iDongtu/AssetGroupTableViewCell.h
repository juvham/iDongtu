//
//  AssetGroupTableViewCell.h
//  iDongtu
//
//  Created by 迅牛 on 15/11/19.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDAssetsThumbnailView.h"
@interface AssetGroupTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet LDAssetsThumbnailView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (void)setData:(PHFetchResult *)data;
@end
