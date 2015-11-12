//
//  NSGIF+livePhoto.m
//  SamplePhotosApp
//
//  Created by 迅牛 on 15/11/10.
//
//

#import "NSGIF+livePhoto.h"
#import <Photos/Photos.h>

#define timeInterval @(600)
#define tolerance    @(0.01)

@implementation NSGIF (livePhoto)

+ (void)createGIFfromLivePhoto:(PHLivePhoto *)livePhoto framesPerSecond:(int)framePerSecond completion:(void (^)(NSURL *))completionBlock {
    
    AVURLAsset *videoAsset = [livePhoto valueForKey:@"videoAsset"];
    
    NSURL *gifUrl = [NSFileManager gifURLWithURL:videoAsset.URL];
    BOOL isExist = [NSFileManager gifExistWithGIFURL:gifUrl];
    
    if (isExist) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Return GIF URL
            completionBlock(gifUrl);
        });
        return;
    }
    
    float videoWidth = [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width;
    float videoHeight = [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height;
    
    GIFSize optimalSize = GIFSizeMedium;
    if (videoWidth >= 1200 || videoHeight >= 1200)
        optimalSize = GIFSizeVeryLow;
    else if (videoWidth >= 800 || videoHeight >= 800)
        optimalSize = GIFSizeLow;
    else if (videoWidth >= 400 || videoHeight >= 400)
        optimalSize = GIFSizeMedium;
    else if (videoWidth < 400|| videoHeight < 400)
        optimalSize = GIFSizeHigh;
    
    float videoLength = (float)videoAsset.duration.value/videoAsset.duration.timescale;
    int framesPerSecond = 30;
    int frameCount = videoLength*framesPerSecond;
    
    NSDictionary *fileProperties = [self filePropertiesWithLoopCount:0];
    NSDictionary *frameProperties = [self framePropertiesWithDelayTime:1.0f/(float)framesPerSecond];
    
    // How far along the video track we want to move, in seconds.
    float increment = (float)videoLength/frameCount;
    
    // Add frames to the buffer
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame<frameCount; ++currentFrame) {
        float seconds = (float)increment * currentFrame;
        CMTime time = CMTimeMakeWithSeconds(seconds, [timeInterval intValue]);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    
    // use Last Frame for thumbnail
    NSValue *value = [timePoints lastObject];
    [timePoints insertObject:value atIndex:0];
    [timePoints removeLastObject];
    
    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *gifURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        gifURL = [self createGIFforTimePoints:timePoints fromURL:videoAsset.URL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:optimalSize];
        
        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(gifURL);
    });


}

@end
