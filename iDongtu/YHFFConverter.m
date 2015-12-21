//
//  YHFFConverter.m
//  iDongtu
//
//  Created by 迅牛 on 15/12/16.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHFFConverter.h"
#import "ffmpeg.h"
#import <AVFoundation/AVFoundation.h>
#include <pthread.h>
#import <libkern/OSAtomic.h>

#import <Photos/Photos.h>

#define ScreenHeight    [UIScreen mainScreen].bounds.size.height
#define ScreenWidth    [UIScreen mainScreen].bounds.size.width


//#define gifFileDirectory   @"/Documents/GIF"

NSString *const palettePath = @"/Documents/GIF/";
NSString *const plattenName = @"palette.png";

@interface NSFileManager (gifPath)


@end

@implementation NSFileManager (gifPath)

+ (NSString *)plattePathWithInputFilePath:(NSString *)inputFilePath {

    NSURL *fileURL = URLWithInputPath(inputFilePath);
    
    //目标路径的文件夹
    fileURL = [fileURL URLByDeletingPathExtension];
    // 判断文件夹是否存在，如果不存在，则创建
    BOOL pathExist = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.absoluteString];
    
    if (!pathExist) {
        //                isDirectory = YES;
        NSError *error;
        BOOL sucess = [[NSFileManager defaultManager] createDirectoryAtPath:fileURL.absoluteString withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"%d",sucess);
    } else {
        NSLog(@"FileDir is exists.");
    }
    
    fileURL = [fileURL URLByAppendingPathComponent:plattenName];
    //删除存在的文件
    if (pathExist) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.absoluteString]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:fileURL.absoluteString error:nil];
        } else {
            
        }
    }
    
    return fileURL.absoluteString;
}

+ (NSString *)gifPathWithInputPath:(NSString *)inputPath {
    
    NSURL *fileURL = URLWithInputPath(inputPath);
    
    fileURL = [fileURL URLByDeletingPathExtension];
    
    fileURL = [fileURL URLByAppendingPathExtension:@"gif"];
    
    return fileURL.absoluteString;

}

//+ ()

//获取输出目标文件URL /usr/..///..///
static NSURL *URLWithInputPath(NSString *inputFilePath) {
    
    NSString *filePath = NSHomeDirectory();
    filePath = [filePath stringByAppendingString:palettePath];
    NSURL *fileURL = [NSURL URLWithString:filePath];
    NSArray *realURL = [[NSURL URLWithString:inputFilePath] pathComponents];
    /*!
     *  @author juvham
     *
     *  @brief  取出最后三级
     */
    for (int i = 3; i > 0; i--) {
        fileURL = [fileURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",[realURL objectAtIndex:realURL.count -i]]];
    }
    
    //目标路径的文件夹
   NSURL * pathURL = [fileURL URLByDeletingPathExtension];
    // 判断文件夹是否存在，如果不存在，则创建
    BOOL pathExist = [[NSFileManager defaultManager] fileExistsAtPath:pathURL.absoluteString];
    
    if (!pathExist) {
        //                isDirectory = YES;
        NSError *error;
        BOOL sucess = [[NSFileManager defaultManager] createDirectoryAtPath:pathURL.absoluteString withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"%d",sucess);
    } else {
        NSLog(@"FileDir is exists.");
    }
    
    
    return fileURL;
    
}

@end
@interface NSString (utf8String)

@end
@implementation NSString (utf8String)


- (char *)utf8StringCopy {
    
    char *utf8String = (char*)malloc(sizeof(char)*1024);
    strcpy(utf8String, [self UTF8String]);
    
    return utf8String;
}

@end

@implementation JHConvertCache
+ (JHConvertCache *)sharedCache {
    
    static JHConvertCache *_sharedCahce;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCahce = [[JHConvertCache alloc] init];
        
        _sharedCahce -> _cachedDic = [NSMutableDictionary dictionary];
    });
    return _sharedCahce;
}

+ (BOOL)inputFileInCahce:(NSString *)inputPath {
    
    JHConvertCache *cache = [JHConvertCache sharedCache];
    
    if ([cache objectInCachedDicForKey:inputPath]) {
        return YES;
    }
    return NO;
}
+ (void)cacheFileForKey:(NSString *)key {
    
    JHConvertCache *cache = [JHConvertCache sharedCache];
    
    [cache setCache:key
             forKey:key];
}
+ (void)removeCacheForKey:(NSString *)key {
    
    JHConvertCache *cache = [JHConvertCache sharedCache];
    [cache removeCacheForKey:key];
}
- (void)setCache:(id)object forKey:(NSString *)key {
    
    [self.cachedDic setObject:object forKey:key];
}
- (void)removeCacheForKey:(NSString *)key {
    
    [self.cachedDic removeObjectForKey:key];
}
- (id)objectInCachedDicForKey:(NSString *)key {
    
    return [self.cachedDic objectForKey:key];
}

@end

@interface YHFFConverter ()
{
    NSThread *paletteThread;
    NSThread *convertThread;
    
//    int result;
}

@property (nonatomic ,copy) NSString *inputFilePath;
@property (nonatomic ,copy) NSString *outputFilePath;
@property (nonatomic ,copy) NSString *palettePath;

@property (nonatomic ,copy) void (^completeBlock)(NSURL*url);

@property (nonatomic ,assign) float startTime;
@property (nonatomic ,assign) float duration;
@property (nonatomic ,assign) float scale;

@property (nonatomic ,strong) dispatch_semaphore_t semaPhore;

@end

@implementation YHFFConverter

static dispatch_queue_t shareConvertGifQueue;
+ (dispatch_queue_t)gifQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
        shareConvertGifQueue = dispatch_queue_create("com.juvham.iDongtu.gif.queue",  attr);
    });
    
    return shareConvertGifQueue;
}

+ (void)load {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)convertMovie:(NSString *)inputFilePath to:(NSString *)outputFilePath scale:(float)scale withStart:(float)startTime andDuration:(float)duration completeBlock:(void (^)(NSURL*url))completeBlock {
   
    YHFFConverter *convert = [[YHFFConverter alloc] init];
    convert.inputFilePath = inputFilePath;
    convert.outputFilePath = outputFilePath;
    convert.startTime = startTime;
    convert.duration = duration;
    convert.scale = scale;
    convert.completeBlock = completeBlock;
    
    [JHConvertCache cacheFileForKey:inputFilePath];
    
    dispatch_group_t convertGroup = dispatch_group_create();
    
    dispatch_group_enter(convertGroup);
    dispatch_async([self gifQueue], ^{
        [convert platten];
        dispatch_group_leave(convertGroup);
    });
    dispatch_group_enter(convertGroup);
    dispatch_async([self gifQueue], ^{
        [convert convert];
        dispatch_group_leave(convertGroup);
    });

    dispatch_group_notify(convertGroup, dispatch_get_main_queue(), ^{
        
        if (convert.completeBlock) {
            completeBlock([NSURL fileURLWithPath:convert.outputFilePath]);
            
        }
    });
    

    
//    [[NSNotificationCenter defaultCenter] addObserver:convert selector:@selector(threadExit:) name:NSThreadWillExitNotification object:nil];
//    
//    convert -> convertThread = [[NSThread alloc] initWithTarget:convert selector:@selector(convert) object:nil];
//    [convert -> convertThread start];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
       
//    });
    
}

- (void)threadExit:(NSNotification *)notification {
    
    if ([notification.object isEqual:self->paletteThread]) {
        
        dispatch_semaphore_signal(self.semaPhore);
    } else {
        
        if ([notification.object isEqual:self->convertThread]) {
            
            if (self.completeBlock) {
                
                self.completeBlock([NSURL fileURLWithPath:self.outputFilePath]);
            }
        }
    }
    NSLog(@"%@",notification);
    
}



- (void)platten {
    
    NSString *plattePath = [NSFileManager plattePathWithInputFilePath:self.inputFilePath];
    NSString *commandLine = [NSString stringWithFormat:@"ffmpeg -v warning -ss %f -t %f -i %@ -vf fps=15,scale=%f:-1:flags=lanczos,palettegen=stats_mode=diff -y %@",self.startTime,self.duration,self.inputFilePath,self.scale,plattePath];
    [self commandline:commandLine];
    self.palettePath = plattePath;
    
}

- (void)convert {
    
    NSString *commandLine = [NSString stringWithFormat:@"ffmpeg -v warning -ss %f -t %f -i %@ -i %@ -lavfi fps=15,scale=%f:-1:flags=lanczos,paletteuse=dither=sierra2_4a -y %@",self.startTime,self.duration,self.inputFilePath,self.palettePath,self.scale,self.outputFilePath];
    
    [self commandline:commandLine];

}

- (int)commandline:(NSString *)commandString {
    
    NSArray *argv_array=[commandString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *arv_copy = [argv_array mutableCopy];
    
//    for (NSString *string in argv_array) {
//        
//        NSString *abString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
//        if (abString.length == 0) {
//            [arv_copy removeObjectAtIndex:[argv_array indexOfObject:string]];
//        }
//    }
    int argc = (int)arv_copy.count;
    char** argv=(char**)malloc(sizeof(char*)*argc);
    for(int i=0;i<argc;i++)
    {
        argv[i]=(char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[arv_copy objectAtIndex:i] UTF8String]);
    }
    
    int result = ffmpeg_main(argc, argv);
    for(int i=0;i<argc;i++)
        free(argv[i]);
    free(argv);
    
    return result;

}

@end

@implementation YHFFConverter (video)

+ (void)convertMovie:(NSString *)inputFilePath withStart:(float)startTime andDuration:(float)duration completeBlock:(void (^)(NSURL *))completeBlock {
    NSString *outputPath = [NSFileManager gifPathWithInputPath:inputFilePath];
    
    NSURL *inputUrl = [NSURL fileURLWithPath:inputFilePath];
        
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        
        if (completeBlock) {
            completeBlock([NSURL fileURLWithPath:outputPath]);
        }
        return;
    } else {
        
        AVURLAsset *asset = [AVURLAsset assetWithURL:inputUrl];
        
        NSString *tmpFilePath = URLWithInputPath(inputFilePath).absoluteString;
    
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:inputFilePath toPath:tmpFilePath error:&error];

        float videoLength = (float)asset.duration.value/asset.duration.timescale;
        
        [self convertMovie:tmpFilePath to:outputPath scale:ScreenWidth withStart:startTime andDuration:MIN(videoLength, duration) completeBlock:completeBlock];
        
    }
    
}

+ (void)convertMovie:(NSString *)inputFilePath withStart:(float)startTime completeBlock:(void (^)(NSURL *))completeBlock {
  
    [self convertMovie:inputFilePath withStart:startTime andDuration:10.0 completeBlock:completeBlock];
}

+ (void)convertMovieWithURL:(NSURL *)url withStart:(float)startTime andDuration:(float)duration completeBlock:(void (^)(NSURL *))completeBlock {
    
     NSString *filePath = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    [self convertMovie:filePath withStart:startTime andDuration:duration completeBlock:completeBlock];
}

+ (void)convertMovieWithURL:(NSURL *)url withStart:(float)startTime completeBlock:(void (^)(NSURL *))completeBlock {
    
    [self convertMovieWithURL:url withStart:startTime andDuration:10 completeBlock:completeBlock];
}

@end

@implementation YHFFConverter (livePhoto)

+ (void)convertLivePhoto:(PHLivePhoto *)livePhoto completion:(void (^)(NSURL *))completionBlock {
    
     AVURLAsset *videoAsset = [livePhoto valueForKey:@"videoAsset"];
    
    [self convertMovieWithURL:videoAsset.URL withStart:0 completeBlock:completionBlock];
    
}

@end
