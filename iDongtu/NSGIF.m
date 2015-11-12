//
//  NSGIF.m
//  
//  Created by Sebastian Dobrincu
//

#import "NSGIF.h"

@implementation NSGIF

// Declare constants

#define timeInterval @(600)
#define tolerance    @(0.01)


#pragma mark - Public methods

+ (void)createGIFfromURL:(NSURL *)videoURL withFramePerSecond:(int)framePerSecond loopCount:(int)loopCount completion:(void (^)(NSURL *))completionBlock {
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    float videoWidth = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width;
    float videoHeight = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height;
    
    GIFSize optimalSize = GIFSizeMedium;
    if (videoWidth >= 1200 || videoHeight >= 1200)
        optimalSize = GIFSizeVeryLow;
    else if (videoWidth >= 800 || videoHeight >= 800)
        optimalSize = GIFSizeLow;
    else if (videoWidth >= 400 || videoHeight >= 400)
        optimalSize = GIFSizeMedium;
    else if (videoWidth < 400|| videoHeight < 400)
        optimalSize = GIFSizeHigh;
    float videoLength = (float)asset.duration.value/asset.duration.timescale;
    
    NSDictionary *fileProperties = [self filePropertiesWithLoopCount:loopCount];
    NSDictionary *frameProperties = [self framePropertiesWithDelayTime:1/30.0];
    
    int frameCount = videoLength*framePerSecond;
    
    // How far along the video track we want to move, in seconds.
    float increment = (float)videoLength/frameCount;
    
    // Add frames to the buffer
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame<frameCount; ++currentFrame) {
        float seconds = (float)increment * currentFrame;
        CMTime time = CMTimeMakeWithSeconds(seconds, [timeInterval intValue]);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    
    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *gifURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        gifURL = [self createGIFforTimePoints:timePoints fromURL:videoURL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:optimalSize];
        
        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(gifURL);
    });
    
    
}

+ (void)optimalGIFfromURL:(NSURL*)videoURL loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock {

    int delayTime = 0.2;
    
    // Create properties dictionaries
    NSDictionary *fileProperties = [self filePropertiesWithLoopCount:loopCount];
    NSDictionary *frameProperties = [self framePropertiesWithDelayTime:delayTime];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    
    float videoWidth = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width;
    float videoHeight = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height;
    
    GIFSize optimalSize = GIFSizeMedium;
    if (videoWidth >= 1200 || videoHeight >= 1200)
        optimalSize = GIFSizeVeryLow;
    else if (videoWidth >= 800 || videoHeight >= 800)
        optimalSize = GIFSizeLow;
    else if (videoWidth >= 400 || videoHeight >= 400)
        optimalSize = GIFSizeMedium;
    else if (videoWidth < 400|| videoHeight < 400)
        optimalSize = GIFSizeHigh;
    
    // Get the length of the video in seconds
    float videoLength = (float)asset.duration.value/asset.duration.timescale;
    int framesPerSecond = 4;
    int frameCount = videoLength*framesPerSecond;
    
    // How far along the video track we want to move, in seconds.
    float increment = (float)videoLength/frameCount;
    
    // Add frames to the buffer
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame<frameCount; ++currentFrame) {
        float seconds = (float)increment * currentFrame;
        CMTime time = CMTimeMakeWithSeconds(seconds, [timeInterval intValue]);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    
    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *gifURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        gifURL = [self createGIFforTimePoints:timePoints fromURL:videoURL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:optimalSize];
        
        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(gifURL);
    });

}

+ (void)createGIFfromURL:(NSURL*)videoURL withFrameCount:(int)frameCount delayTime:(float)delayTime loopCount:(int)loopCount gifSize:(GIFSize)gifSize completion:(void (^)(NSURL *))completionBlock {
    
    // Convert the video at the given URL to a GIF, and return the GIF's URL if it was created.
    // The frames are spaced evenly over the video, and each has the same duration.
    // delayTime is the amount of time for each frame in the GIF.
    // loopCount is the number of times the GIF will repeat. Defaults to 0, which means repeat infinitely.
    
    // Create properties dictionaries
    NSDictionary *fileProperties = [self filePropertiesWithLoopCount:loopCount];
    NSDictionary *frameProperties = [self framePropertiesWithDelayTime:delayTime];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];

    // Get the length of the video in seconds
    float videoLength = (float)asset.duration.value/asset.duration.timescale;
    
    // How far along the video track we want to move, in seconds.
    float increment = (float)videoLength/frameCount;
    
    // Add frames to the buffer
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame<frameCount; ++currentFrame) {
        float seconds = (float)increment * currentFrame;
        CMTime time = CMTimeMakeWithSeconds(seconds, [timeInterval intValue]);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }

    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *gifURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        gifURL = [self createGIFforTimePoints:timePoints fromURL:videoURL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:gifSize];

        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(gifURL);
    });
    
}

#pragma mark - Base methods

+ (NSURL *)createGIFforTimePoints:(NSArray *)timePoints fromURL:(NSURL *)url fileProperties:(NSDictionary *)fileProperties frameProperties:(NSDictionary *)frameProperties frameCount:(int)frameCount gifSize:(GIFSize)gifSize{
    
    NSURL *fileURL = [NSFileManager gifURLWithURL:url];

    NSString *dirPath = [fileURL URLByDeletingLastPathComponent].absoluteString;
    
    dirPath = [dirPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    BOOL isDirectory;
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectory]) {
        
        //                isDirectory = YES;
        NSError *error;
        BOOL sucess = [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:dirPath] withIntermediateDirectories:YES attributes:nil error:&error];
        
        NSLog(@"%d",sucess);
    } else {
        NSLog(@"FileDir is exists.");
    }
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF , frameCount, NULL);
    
    if (fileURL == nil)
        return nil;
    if (destination == nil) {
        return nil;
    }

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime tol = CMTimeMakeWithSeconds([tolerance floatValue], [timeInterval intValue]);
    generator.requestedTimeToleranceBefore = tol;
    generator.requestedTimeToleranceAfter = tol;
    
    NSError *error = nil;
    
    for (NSValue *time in timePoints) {
        CGImageRef imageRef;
        
        imageRef = [generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error];
        #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        CGImageRef newImage = CGImageRetain(imageRef);
        CGImageRelease(imageRef);
        float scale = (float)gifSize/10.0;
        if (scale != 1) {
           imageRef = ImageWithScale(newImage, scale);
        } else {

        }
        CGImageRelease(newImage);
        #elif TARGET_OS_MAC
        #endif
        
        CGImageDestinationAddImage(destination, imageRef,  (CFDictionaryRef)frameProperties);
        CGImageRelease(imageRef);
    }
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
    // Finalize the GIF
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to finalize GIF destination: %@", error);
        return nil;
    }
    CFRelease(destination);
    
    return fileURL;
}

#pragma mark - Helpers

CGImageRef ImageWithScale(CGImageRef imageRef, float scale) {
    
    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    CGSize newSize = CGSizeMake(CGImageGetWidth(imageRef)*scale, CGImageGetHeight(imageRef)*scale);
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
//    
//    CGDataProviderDirectCallbacks callbacks = {
//        .version = 0,
//        .getBytePointer = NULL,
//        .releaseBytePointer = NULL,
//        .getBytesAtPosition = getAssetBytesCallback,
//        .releaseInfo = releaseAssetCallback,
//    };
//    
//    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
//    CGImageRelease(imageRef);
//    
//    CGImageSourceRef sourceref = CGImageSourceCreateWithDataProvider(dataProvider, NULL);
////
//    imageRef = CGImageSourcec

    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return nil;
    }
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    imageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    #endif
    
    return imageRef;
}

#pragma mark - Properties

+ (NSDictionary *)filePropertiesWithLoopCount:(int)loopCount {
    
    return @{ (__bridge NSString *)kCGImagePropertyGIFDictionary:
                @{(__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}
             };
}

+ (NSDictionary *)framePropertiesWithDelayTime:(float)delayTime {

    return @{(__bridge_transfer  NSString *)kCGImagePropertyGIFDictionary:
                @{(__bridge_transfer NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
                (__bridge_transfer NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB
            };
}

@end
