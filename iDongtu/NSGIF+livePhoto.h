//
//  NSGIF+livePhoto.h
//  SamplePhotosApp
//
//  Created by 迅牛 on 15/11/10.
//
//

#import "NSGIF.h"
@class PHLivePhoto;
@interface NSGIF (livePhoto)

+ (void)createGIFfromLivePhoto:(PHLivePhoto*)livePhoto framesPerSecond:(int)framePerSecond completion:(void(^)(NSURL *GifURL))completionBlock;

@end
