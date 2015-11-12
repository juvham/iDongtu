//
//  CCPRequestOperation.h
//  CloudPush
//
//  Created by wuxiang on 14-8-14.
//  Change by madding.lip at 2015.07.06
//  Copyright (c) 2014年 ___alibaba___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPURLRequest.h"
#import "CCPURLResponse.h"

typedef void (^successCallBack)(CCPURLRequest *ccpRequest,
                                CCPURLResponse *ccpResponse);

typedef void (^failureCallBack)(CCPURLRequest *ccpRequest,
                                CCPURLResponse *ccpResponse, NSError *error);

@interface CCPRequestOperation : NSObject

- (void)doRequest:(CCPURLRequest *)request
          success:(successCallBack)success
          failure:(failureCallBack)failure
          timeout:(NSTimeInterval)timeout;

/**
 *   http
 *
 *  @param ccpRequest      request 请求
 *  @param successCallBack 成功回调
 *  @param failureCallBack 失败回调
 */
- (void)doHttpRequest:(CCPURLRequest *)request
              success:(successCallBack)success
              failure:(failureCallBack)failure;

- (void)doHttpRequest:(CCPURLRequest *)request
              success:(successCallBack)success
              failure:(failureCallBack)failure
              timeout:(NSTimeInterval)timeout;

/**
 *  tcp
 *
 *  @param ccpRequest request 请求
 *  @param successCallBack 成功回调
 *  @param failureCallBack 失败回调
 */
- (void)doRpcRequest:(CCPURLRequest *)request
             success:(successCallBack)success
             failure:(failureCallBack)failure;

- (void)doRpcRequest:(CCPURLRequest *)request
             success:(successCallBack)success
             failure:(failureCallBack)failure
             timeout:(NSTimeInterval)timeout;

/**
 *  http同步请求
 */
- (BOOL)sendHttpSyncRequest:(CCPURLRequest *)request
                   response:(CCPURLResponse **)response
                      error:(NSError **)error;

/**
 *  http异步请求
 */
- (void)sendHttpAsyncRequest:(CCPURLRequest *)request
                     success:(successCallBack)success
                     failure:(failureCallBack)failure;

/**
 * tcp同步请求
 * no impl
 */
- (BOOL)sendTcpSyncRequest:(CCPURLRequest *)request
                  response:(CCPURLResponse **)response
                     error:(NSError **)error;

/**
 * tcp异步请求
 * no impl
 */
- (void)sendTcpAsyncRequest:(CCPURLRequest *)request
                    success:(successCallBack)success
                    failure:(failureCallBack)failure;

/**
 * udp同步请求
 * no impl
 */
- (BOOL)sendUdpSyncRequest:(CCPURLRequest *)request
                  response:(CCPURLResponse **)response
                     error:(NSError **)error;

/**
 * udp异步请求
 * no impl
 */
- (void)sendUdpAsyncRequest:(CCPURLRequest *)request
                    success:(successCallBack)success
                    failure:(failureCallBack)failure;

@end
