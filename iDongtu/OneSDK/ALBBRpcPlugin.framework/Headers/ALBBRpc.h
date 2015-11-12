//
//  ALBBRpc.h
//  ALBBRpc
//
//  Created by wuxiang on 15/4/21.
//  Copyright (c) 2015年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPURLRequest.h"
#import "CCPRequestOperation.h"

// constants
#define ALBB_RPC_PLUGIN_VERSION @"1.2.8"


@interface ALBBRpc : NSObject

/**
 * 默认使用tcp请求，没有使用http请求
 */
+(void) executeRequest:(CCPURLRequest *)request
               success:(successCallBack)success
               failure:(failureCallBack)failure
               timeout:(NSTimeInterval)timeout;


/**
 *  http请求
 */
+(void) executeHttpRequest:(CCPURLRequest *)request
                   success:(successCallBack)success
                   failure:(failureCallBack)failure
                   timeout:(NSTimeInterval)timeout;

// 兼容老代码，useless
+(NSString *) getVersion;

+(NSString *) getGateWayUrl;

@end
