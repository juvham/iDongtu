//
//  ALBBRpcService.h
//  TAESDK
//
//  Created by zhoulai on 15/6/9.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ALBBSessionProvider.h>

/** RPC服务 */
@protocol ALBBRpcService<NSObject>
/** 同步RPC */
@required
- (id)executeSynchronous:(NSString *)target
                 version:(NSString *)version
                  params:(NSDictionary *)params
                provider:(id<ALBBSessionProvider>)provider;
/** 同步RPC */
@required
- (id)executeSynchronous:(NSString *)target
                 version:(NSString *)version
                  params:(NSDictionary *)params
                  domain:(NSString *)domain
                provider:(id<ALBBSessionProvider>)provider;
/** 异步RPC */
@required
- (void)executeAsynchronous:(NSString *)target
                    version:(NSString *)version
                     params:(NSDictionary *)params
                   provider:(id<ALBBSessionProvider>)provider
                    success:(void (^)(id rpcResult))success
                    failure:(void (^)(NSError *rpcError))failure;
/** 异步RPC */
@required
- (void)executeAsynchronous:(NSString *)target
                    version:(NSString *)version
                     params:(NSDictionary *)params
                     domain:(NSString *)domain
                   provider:(id<ALBBSessionProvider>)provider
                    success:(void (^)(id rpcResult))success
                    failure:(void (^)(NSError *rpcError))failure;

/** 同步RPC,coreSession */
@required
- (id)executeSynchronousWithCoreSession:(NSString *)target
                 version:(NSString *)version
                  params:(NSDictionary *)params;

/** 异步RPC,coreSession */
@required
- (void)executeAsynchronous:(NSString *)target
                    version:(NSString *)version
                     params:(NSDictionary *)params
                    success:(void (^)(id rpcResult))success
                    failure:(void (^)(NSError *rpcError))failure;
@end
