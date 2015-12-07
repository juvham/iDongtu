/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying an asset full screen.
 */

@import UIKit;
@import Photos;

#import "AAPLAssetGridViewController.h"

@interface AAPLAssetViewController : UIViewController

+ (instancetype )photoViewControllerForPageIndex:(NSUInteger)pageIndex collectionDelegate:(AAPLAssetGridViewController *)collectionDelegate;

@property (nonatomic ,assign) NSUInteger pageIndex;

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) AAPLAssetGridViewController *collectionDelegate;
@property (nonatomic, assign) UIViewController *toolBarDelegate;

@end
