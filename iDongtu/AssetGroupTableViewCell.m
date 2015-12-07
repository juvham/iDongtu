//
//  AssetGroupTableViewCell.m
//  iDongtu
//
//  Created by 迅牛 on 15/11/19.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import "AssetGroupTableViewCell.h"

@implementation AssetGroupTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(PHFetchResult *)data {
    
    self.thumbnailImage.assetsGroup = data;
    
    self.countLabel.text = [NSString stringWithFormat:@"(%lu)",(unsigned long)data.count];
}

@end
