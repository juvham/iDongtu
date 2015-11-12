//
//  TaeTopClient.h
//  TAESDK
//
//  Created by 友和(lai.zhoul@alibaba-inc.com) on 14-9-27.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^topRequestCallback)(NSString *result);

@interface TaeTopClient : NSObject

/**
 * top api调用原始文档见http://open.taobao.com/doc/detail.htm?id=101617
 *
 *1.post data可以传入的参数包括:method,format,v,fields
 *2.url 为请求的地http地址
 */
+(void) doRequest:(NSDictionary*)postData
              url:(NSString *)url
       onComplete:(topRequestCallback)onComplete;
@end
