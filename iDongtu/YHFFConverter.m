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
    NSString *commandLine = [NSString stringWithFormat:@"ffmpeg -v warning   -ss %f -t %f -i %@ -vf   \"fps=15,scale=%f:-1:flags=lanczos,palettegen=stats_mode=diff\" -y %@",self.startTime,self.duration,self.inputFilePath,self.scale,plattePath];
    [self commandline:commandLine];
    self.palettePath = plattePath;
    
}

- (void)convert {
    
    NSString *commandLine = [NSString stringWithFormat:@"ffmpeg -v warning -ss %f -t %f -i %@ -i  %@   -lavfi \"fps=15,scale=%f:-1:flags=lanczos [x];[x][1:v] paletteuse=dither=sierra2_4a\" -y %@",self.startTime,self.duration,self.inputFilePath,self.palettePath,self.scale,self.outputFilePath];
    
//    getopt(<#int#>, <#char *const *#>, <#const char *#>)
    
    [self commandline:commandLine];

}

- (int)commandline:(NSString *)commandString {

    int argc;
    char **argv = parse_argvs(commandString, &argc);
    int result = ffmpeg_main(argc, argv);
    return result;

}
#pragma mark - inline Function
static inline char ** parse_argvs(const NSString  *cmd , int *argc)
/*
 * 将长串命令行按空格分割为字符串数组
 */
{
    NSArray *arcArray = [cmd componentsSeparatedByString:@" "];
    NSMutableArray *arcArray_copy = [arcArray mutableCopy];
    [arcArray_copy removeObject:@""];
    arcArray = [arcArray_copy copy];
    
    __block NSUInteger subStart = NSIntegerMax;
    __block NSUInteger subEnd = NSIntegerMax;
    
    [arcArray_copy removeAllObjects];
    [arcArray enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (subStart == NSNotFound) {
            
            //找到带引号字符串开头
            if ([string hasPrefix:@"\""] ) {
                subStart = idx;
                if ([string hasSuffix:@"\""] ) {
                    NSString *pString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    
                    if (pString.length == 0) {
                        //一个字符串就一个引号 从下个字符串开始处理
                        subStart ++;
                        
                    } else {
                        //前后引号在同一个字符串
                        [arcArray_copy addObject:pString];
                        subStart = NSNotFound;
                        subEnd = NSNotFound;
                    }
                }
            } else {
                //正常字符串
                [arcArray_copy addObject:string];
            }
            
        } else {
            //开始处理子字符串了
            
            if ([string hasPrefix:@"\""] ) {
                //arcArray_copy
                
                if ([string hasSuffix:@"\""]) {
                    //一个字符串就一个引号
                    NSString *pString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    
                    if (pString.length == 0) {
                        //一个字符串就一个引号 从上个字符串开始处理
                        subEnd = idx - 1;
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(subStart, (subEnd-subStart) + 1)];
                        NSArray *subArray = [arcArray objectsAtIndexes:indexSet];
                        NSString *pString = [subArray componentsJoinedByString:@" "];
                        pString = [pString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                        [arcArray_copy addObject:pString];
                        subStart = NSNotFound;
                        subEnd = NSNotFound;
                        
                    } else {
                      //引号不配对
                        *stop = YES;
                    }
                    
                } else {
                    //引号不配对
                    *stop = YES;
                }
                if (*stop) {
                    [arcArray_copy removeAllObjects];
                }

            } else if ([string hasSuffix:@"\""]) {
                
                //找到带引号字符串结尾
                subEnd = idx;
                //有引号字符串开头
                    //在同一个字符串
                    if (subEnd == subStart) {
                        //去掉引号
                        //这种情况在上面处理掉了
                    } else if (subEnd > subStart) {
                        //在不同字符串
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(subStart, (subEnd-subStart) +1)];
                        NSArray *subArray = [arcArray objectsAtIndexes:indexSet];
                        NSString *pString = [subArray componentsJoinedByString:@" "];
                        pString = [pString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                        [arcArray_copy addObject:pString];

                    } else {
                        
                        //经过上次的判断这种情况不应当出现
                    }
                // 处理完成 重置 继续下面的处理
                subStart = NSNotFound;
                subEnd = NSNotFound;
            }
        }
    }];
    
    NSLog(@"%@",arcArray_copy);
    
    *argc = (int)arcArray_copy.count;

    char **argvs = (char**)malloc(sizeof(char*)*arcArray_copy.count);
//    *argv=
    for(int i=0;i< arcArray_copy.count;i++)
    {
        const char *str = [[arcArray_copy objectAtIndex:i] UTF8String];
        argvs[i]=(char*)malloc(sizeof(char)*strlen(str));
        strcpy(argvs[i],str);
    }
    return argvs;
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
