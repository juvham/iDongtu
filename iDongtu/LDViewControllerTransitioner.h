//
//  LDViewControllerTransitioner.h
//  lingdang2
//
//  Created by AceElvis on 15/4/14.
//  Copyright (c) 2015年 GouMin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAPLGridViewCell.h"

@interface LDControllerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface LDNavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

- (instancetype)initWithNavigationController:(UINavigationController *)naviController;

@property (nonatomic ,assign)  AAPLGridViewCell *animationCell;
@property (nonatomic ,assign) CGRect targetRect;

@end

@interface LDControllerTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end
