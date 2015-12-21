//
//  YHFFConverter.h
//  iDongtu
//
//  Created by 迅牛 on 15/12/16.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHLivePhoto;

@interface JHConvertCache : NSObject;
@property (nonatomic ,strong ,readonly ) NSMutableDictionary *cachedDic;
+ (JHConvertCache *)sharedCache;

+ (BOOL)inputFileInCahce:(NSString *)inputPath;
- (id)objectInCachedDicForKey:(NSString *)key;
- (void)setCache:(id)object forKey:(NSString *)key;
+ (void)cacheFileForKey:(NSString *)key;
- (void)removeCacheForKey:(NSString *)key;
+ (void)removeCacheForKey:(NSString *)key;

@end

@interface YHFFConverter : NSObject
// outputPath的 path extesion 决定了转码的格式
+ (void)convertMovie:(NSString *)inputFilePath to:(NSString *)outputFilePath scale:(float)scale withStart:(float)startTime andDuration:(float)duration completeBlock:(void (^)(NSURL*url))completeBlock;

@end

@interface YHFFConverter (livePhoto)

+ (void)convertLivePhoto:(PHLivePhoto*)livePhoto completion:(void(^)(NSURL *gifURL))completionBlock;

@end

@interface YHFFConverter (video)

+ (void)convertMovie:(NSString *)inputFilePath withStart:(float)startTime andDuration:(float)duration completeBlock:(void (^)(NSURL *gifURL))completeBlock;
//最大10秒的方法
+ (void)convertMovie:(NSString *)inputFilePath withStart:(float)startTime completeBlock:(void (^)(NSURL *gifURL))completeBlock;

+ (void)convertMovieWithURL:(NSURL *)url withStart:(float)startTime andDuration:(float)duration completeBlock:(void (^)(NSURL *gifURL))completeBlock;
//最大10秒的方法
+ (void)convertMovieWithURL:(NSURL *)url withStart:(float)startTime completeBlock:(void (^)(NSURL *gifURL))completeBlock;



@end
