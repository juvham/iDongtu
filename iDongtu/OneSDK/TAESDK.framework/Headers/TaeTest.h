//
//  TaeTest.h
//  taesdk
//
//  Created by 友和(lai.zhoul@alibaba-inc.com) on 14-8-2.
//  Copyright (c) 2014年 com.taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface TaeTest : NSObject

+(NSString *) test:(UIViewController *) parentController;//test方法
+(void) resetTaeSDKDemo;//删除sdk数据项
+(BOOL) isNetWorkOK;

/***********************************/
@end
