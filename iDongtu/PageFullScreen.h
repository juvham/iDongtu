//
//  PageFullScreen.h
//  iDongtu
//
//  Created by 迅牛 on 15/11/26.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageFullScreen : NSObject

+ (instancetype)sharedManager;

+ (BOOL)fullScreenMode;
+ (void)setFullScreenMode:(BOOL)fullScreen;

@end
