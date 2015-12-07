//
//  PageFullScreen.m
//  iDongtu
//
//  Created by 迅牛 on 15/11/26.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import "PageFullScreen.h"
@interface PageFullScreen ()

@property (nonatomic, assign) BOOL fullScreenMode;
@end

@implementation PageFullScreen

+ (instancetype)sharedManager {
    
    static PageFullScreen *full;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
    full = [[PageFullScreen alloc] init];
        
    });
    
    return full;
}

+ (BOOL)fullScreenMode {
    
    return [PageFullScreen sharedManager].fullScreenMode;
}

+ (void)setFullScreenMode:(BOOL)fullScreen {
    
    [PageFullScreen sharedManager].fullScreenMode = fullScreen;
}
@end
