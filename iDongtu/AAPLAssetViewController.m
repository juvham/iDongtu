 /*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying an asset full screen.
 */

#import "AAPLAssetViewController.h"
#import "CIImage+Convenience.h"
#import "NSGIF+livePhoto.h"
#import "ShareViewController.h"
#import "GifAssetHelper.h"
#import "PageFullScreen.h"
#import "YHFFConverter.h"
@import PhotosUI;

@interface AAPLAssetViewController () <PHPhotoLibraryChangeObserver, PHLivePhotoViewDelegate>

@property (nonatomic, weak) IBOutlet PHLivePhotoView *livePhotoView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *space;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *trashButton;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) CGSize lastTargetSize;
@property (nonatomic, assign) BOOL playingHint;

//@property ()

@end

@implementation AAPLAssetViewController

static NSString * const AdjustmentFormatIdentifier = @"com.example.apple-samplecode.SamplePhotosApp";

#pragma mark - View Lifecycle Methods.

+ (instancetype)photoViewControllerForPageIndex:(NSUInteger)pageIndex collectionDelegate:(AAPLAssetGridViewController *)collectionDelegate {
    
    if (pageIndex < [collectionDelegate.assetsFetchResults count])
    {
        AAPLAssetViewController *viewController = [collectionDelegate.storyboard instantiateViewControllerWithIdentifier:@"AAPLAssetViewController"];
    
        viewController.view.frame = [UIScreen mainScreen].bounds;
        viewController.pageIndex = pageIndex;
        viewController.collectionDelegate = collectionDelegate;
        viewController.asset = [collectionDelegate.assetsFetchResults objectAtIndex:pageIndex];
        [viewController cacheImage];
        return viewController;
    }
    
    return nil;
    
}
- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.livePhotoView.delegate = self;
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the appropriate toolbarItems based on the mediaType of the asset.
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        [self showPlaybackToolbar];
    } else {
        
        [self showStaticToolbar];
    }
    // Enable the edit button if the asset can be edited.
    BOOL isEditable = ([self.asset canPerformEditOperation:PHAssetEditOperationProperties] || [self.asset canPerformEditOperation:PHAssetEditOperationContent]);
    self.editButton.enabled = isEditable;
    
    // Enable the trash button if the asset can be deleted.
    BOOL isTrashable = NO;
    if (self.collectionDelegate.assetCollection) {
        isTrashable = [self.collectionDelegate.assetCollection canPerformEditOperation:PHCollectionEditOperationRemoveContent];
    } else {
        
        isTrashable = [self.asset canPerformEditOperation:PHAssetEditOperationDelete];
    }
    self.trashButton.enabled = isTrashable;
    
    [self showNavigationItem];
    
    [self updateImage];

    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.collectionDelegate.currentIndex = self.pageIndex;
}
#pragma mark - View & Toolbar setup methods.

- (void)showNavigationItem {
    
    self.toolBarDelegate.navigationItem.leftBarButtonItems = self.navigationItem.leftBarButtonItems;
    self.toolBarDelegate.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
    self.toolBarDelegate.navigationItem.titleView = self.navigationItem.titleView;
}

- (void)showLivePhotoView {
    self.livePhotoView.hidden = NO;
    self.imageView.hidden = YES;
   
}

- (void)showStaticPhotoView {
    self.livePhotoView.hidden = YES;
    self.imageView.hidden = NO;
}

- (void)showPlaybackToolbar {
    
    [self.toolBarDelegate setToolbarItems:@[self.playButton, self.space, self.trashButton] animated:YES];
  
}

- (void)showStaticToolbar {
        [self.toolBarDelegate setToolbarItems:@[self.space, self.trashButton] animated:YES];
    
}

- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
    return targetSize;
}

#pragma mark - ImageView/LivePhotoView Image Setting methods.

- (void)updateImage {
    self.lastTargetSize = [self targetSize];

    // Check the asset's `mediaSubtypes` to determine if this is a live photo or not.
    BOOL assetHasLivePhotoSubType = (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive);
    if (assetHasLivePhotoSubType) {
        [self updateLiveImage];
    
    }
    else {
        [self updateStaticImage];
    }
}

- (void)cacheImage {
    
    [[GifAssetHelper sharedAssetHelper] startCachingImagesForAssets:@[self.asset] targetSize:[self targetSize]  contentMode:PHImageContentModeAspectFit];
}

- (void)updateLiveImage {
    // Prepare the options to pass when fetching the live photo.
    PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
    livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    livePhotoOptions.networkAccessAllowed = YES;
    __weak typeof(self) weakSelf = self;
    livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
            Progress callbacks may not be on the main thread. Since we're updating
            the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
        });
    };
    
    self.editButton.enabled = YES;
    
    // Request the live photo for the asset from the default PHImageManager.
    [[GifAssetHelper sharedAssetHelper] requestLivePhotoForAsset:self.asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:livePhotoOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        // Hide the progress view now the request has completed.
        weakSelf.progressView.hidden = YES;
        
        // Check if the request was successful.
        if (!livePhoto) {
            return;
        }
        
        NSLog (@"Got a live photo");

        // Show the PHLivePhotoView and use it to display the requested image.
        [weakSelf showLivePhotoView];
        weakSelf.livePhotoView.livePhoto = livePhoto;
        
        if (![info[PHImageResultIsDegradedKey] boolValue] && !weakSelf.playingHint) {
            // Playback a short section of the live photo; similar to the Photos share sheet.
            NSLog (@"playing hint...");
            weakSelf.playingHint = YES;
            [weakSelf.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
        }
        
        // Update the toolbar to show the correct items for a live photo.
        [weakSelf showPlaybackToolbar];
    
    
    }];
    
}

- (void)updateStaticImage {
    // Prepare the options to pass when fetching the live photo.
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    __weak typeof(self) weakSelf = self;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
            Progress callbacks may not be on the main thread. Since we're updating
            the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
        });
    };
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        
        self.editButton.enabled = YES;
    } else {
        
        self.editButton.enabled = NO;
    }
    
    [[GifAssetHelper sharedAssetHelper] requestImageForAsset:self.asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Hide the progress view now the request has completed.
        weakSelf.progressView.hidden = YES;
        
        // Check if the request was successful.
        if (!result) {
            return;
        }
        
        // Show the UIImageView and use it to display the requested image.
        [weakSelf showStaticPhotoView];
        weakSelf.imageView.image = result;
    }];
}

- (IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue {
    
    
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check if there are changes to the asset we're displaying.
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:weakSelf.asset];
        if (changeDetails == nil) {
            return;
        }
        
        // Get the updated asset.
        weakSelf.asset = [changeDetails objectAfterChanges];
        
        // If the asset's content changed, update the image and stop any video playback.
        if ([changeDetails assetContentChanged]) {
            [weakSelf updateImage];
            
            [weakSelf.playerLayer removeFromSuperlayer];
            weakSelf.playerLayer = nil;
        }
    });
}

- (BOOL)checkCurrentIsShow {
    
    PHAsset *asset = [self.collectionDelegate.assetsFetchResults objectAtIndex:self.collectionDelegate.currentIndex];
    if ([asset isEqual:self.asset]) {
        
        return YES;
    }
    
    return NO;
    
}
#pragma mark - Target Action Methods.

- (IBAction)handleEditButtonItem:(id)sender {
 
    __weak typeof(self) weakSelf = self;
    
    if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        
        AVURLAsset *videoAsset = [self.livePhotoView.livePhoto valueForKey:@"videoAsset"];
        
        if ([JHConvertCache inputFileInCahce:videoAsset.URL.absoluteString]) {
            
        } else {
            
            [JHConvertCache cacheFileForKey:videoAsset.URL.absoluteString];
            [YHFFConverter convertLivePhoto:self.livePhotoView.livePhoto completion:^(NSURL *gifURL) {
               
                [JHConvertCache removeCacheForKey:videoAsset.URL.absoluteString];
                if ([weakSelf checkCurrentIsShow]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf performSegueWithIdentifier:shareViewControllerSegueID sender:gifURL];
                        [weakSelf writeToAssetCollection:gifURL];
                    });
                }
                
            }];
        }
        
    } else if (self.asset.mediaType & PHAssetMediaTypeVideo) {
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            
            AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
            
            
            
            if ([avAsset isKindOfClass:[AVURLAsset class]]) {
                
                if ([JHConvertCache inputFileInCahce:urlAsset.URL.absoluteString]) {
                    
                } else {
                    
                    [JHConvertCache cacheFileForKey:urlAsset.URL.absoluteString];
                    
                    [YHFFConverter convertMovieWithURL:urlAsset.URL withStart:0 completeBlock:^(NSURL *gifURL) {
                        [JHConvertCache removeCacheForKey:urlAsset.URL.absoluteString];
                        if ([weakSelf checkCurrentIsShow]) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf performSegueWithIdentifier:shareViewControllerSegueID sender:gifURL];
                                
                                [weakSelf writeToAssetCollection:gifURL];
                            });
                        }
                    }];
                }
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakSelf.parentViewController.navigationItem.prompt = @"视频文件获取失败";
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.parentViewController.navigationItem.prompt = nil;
                    
                });
                
            }
        }];
    }
}
- (void)writeToAssetCollection:(NSURL *)url {
    
    // Add it to the photo library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
        
        if ([GifAssetHelper sharedAssetHelper].assetCollection) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:[GifAssetHelper sharedAssetHelper].assetCollection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        }
    }];

    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ShareViewController class]]) {
        
        ShareViewController *viewController = (ShareViewController *)segue.destinationViewController;
        
        viewController.URL = sender;
    }
    
}

- (IBAction)handleTrashButtonItem:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[weakSelf navigationController] popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    if (self.collectionDelegate.assetsFetchResults) {
        // Remove asset from album
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:weakSelf.collectionDelegate.assetCollection];
//            [changeRequest removeAssets:@[weakSelf.asset]];
//        } completionHandler:completionHandler];
        
//    } else {
        // Delete asset from library
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[weakSelf.asset]];
        } completionHandler:completionHandler];
        
    }
}

- (IBAction)handlePlayButtonItem:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    if (self.livePhotoView.livePhoto != nil) {
        // We're displaying a live photo, begin playing it.
        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    } else if (self.playerLayer != nil) {
        // An AVPlayerLayer has already been created for this asset.
        [self.playerLayer.player play];
    }
    else {
        // Request an AVAsset for the PHAsset we're displaying.
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf.playerLayer) {
                    CALayer *viewLayer = weakSelf.view.layer;
                    
                    // Create an AVPlayerItem for the AVAsset.
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                    playerItem.audioMix = audioMix;
                    
                    // Create an AVPlayer with the AVPlayerItem.
                    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                    
                    // Create an AVPlayerLayer with the AVPlayer.
                    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                    
                    // Configure the AVPlayerLayer and add it to the view.
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                    playerLayer.frame = CGRectMake(0, 0, viewLayer.bounds.size.width, viewLayer.bounds.size.height);
                    
                    [viewLayer addSublayer:playerLayer];
                    [player play];
                    
                    // Store a reference to the player layer we added to the view.
                    weakSelf.playerLayer = playerLayer;
                }
            });
        }];
    }
}

#pragma mark - PHLivePhotoViewDelegate Protocol Methods.

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    NSLog(@"Will Beginning Playback of Live Photo...");
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    NSLog(@"Did End Playback of Live Photo...");
    self.playingHint = NO;
}

#pragma mark - Photo editing methods.

- (void)applyFilterWithName:(NSString *)filterName {
    // Prepare the options to pass when requesting to edit the image.
    __weak typeof(self) weakSelf = self;
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    [options setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmentData) {
        return [adjustmentData.formatIdentifier isEqualToString:AdjustmentFormatIdentifier] && [adjustmentData.formatVersion isEqualToString:@"1.0"];
    }];
    
    [self.asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
        // Create a CIImage from the full image representation.
        NSURL *url = [contentEditingInput fullSizeImageURL];
        int orientation = [contentEditingInput fullSizeImageOrientation];
        CIImage *inputImage = [CIImage imageWithContentsOfURL:url options:nil];
        inputImage = [inputImage imageByApplyingOrientation:orientation];

        // Create the filter to apply.
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setDefaults];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        
        // Apply the filter.
        CIImage *outputImage = [filter outputImage];

        // Create a PHAdjustmentData object that describes the filter that was applied.
        PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:AdjustmentFormatIdentifier formatVersion:@"1.0" data:[filterName dataUsingEncoding:NSUTF8StringEncoding]];
        
        /*
            Create a PHContentEditingOutput object and write a JPEG representation
            of the filtered object to the renderedContentURL.
         */
        PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:contentEditingInput];
        NSData *jpegData = [outputImage aapl_jpegRepresentationWithCompressionQuality:0.9f];
        [jpegData writeToURL:[contentEditingOutput renderedContentURL] atomically:YES];
        [contentEditingOutput setAdjustmentData:adjustmentData];
        
        // Ask the shared PHPhotoLinrary to perform the changes.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:weakSelf.asset];
            request.contentEditingOutput = contentEditingOutput;
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error: %@", error);
            }
        }];
    }];
}

- (void)toggleFavoriteState {
    
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:weakSelf.asset];
        [request setFavorite:![weakSelf.asset isFavorite]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)revertToOriginal {
        __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:weakSelf.asset];
        [request revertAssetContentToOriginal];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error: %@", error);
        }
    }];
}

@end
