//
//  CCPURLResponse.h
//  CloudPush
//
//  Created by wuxiang on 14-8-14.
//  Copyright (c) 2014年 ___alibaba___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCPURLResponse : NSObject

/**
 * rpc返回错误码
 */
enum {
  /** useless code */
  // cloudpush在使用
  RPC_ERROR_CHANNEL_NOT_READY = 0,
  // old code
  RPC_ERROR_CHANNEL_DECODE_ERROR = -1,
  // old code
  RPC_ERROR_CHANNEL_SERVICE_GATEWAY_BAD = 500,
  // old code
  RPC_ERROR_CHANNEL_SERVICE_UNAVAILABLE = 503,

  /** usefull code */
  // sid解析异常、sid解析得到null
  RPC_ERROR_CHANNEL_SID_INVLID = 1,
  // authSession 解析出 SeedKey 为空
  RPC_ERROR_CHANNEL_AUTH_SESSION_SEEDKEY_NULL = 2,
  // 调用后端HSF异常
  RPC_ERROR_CHANNEL_RPC_TIMEOUT = 3,
  // http请求错误
  RPC_ERROR_CHANNEL_HTTP_ERROR = 4,
  // API 不存在或者不合法
  RPC_ERROR_CHANNEL_API_NOT_RECOGINZE = 6,
  // APP 不存在或者不合法
  RPC_ERROR_CHANNEL_APP_NOR_RECOGINZE = 7,
  // APP 没有调用API的权限
  RPC_ERROR_CHANNEL_NO_PERMISSION = 8,
  // API调用流控 子错误码
  RPC_ERROR_CHANNEL_API_FLOW_CONTROL = 9,
  // http中etag相同
  RPC_ERROR_CHANNEL_ETAG_IS_EQUAL = 304,
  //
  RPC_ERROR_CHANNEL_MAY_SID_IS_INVALID = 401,
  // resource不存在
  RPC_ERROR_CHANNEL_SERVICE_NOT_FOUND = 404,
  // API调用重放
  RPC_ERROR_CHANNEL_API_REPEAT_INVOKE = 416,
  // http Body 解密异常
  RPC_ERROR_CHANNEL_BODY_DECODE_ERROR = 502,
  // 调用后端HSF超时
  RPC_ERROR_CHANNEL_SERVICE_TIMEOUT = 504

};

@property(nonatomic, strong) NSData *data;
@property(nonatomic, strong) NSData *serviceResult;
@property(nonatomic, strong) NSMutableDictionary *responseHeaders;
// 序列化的类型（0：原始数据）
@property(nonatomic) UInt8 contentType;
// 序列化的类型（0：原始数据）
@property(nonatomic) NSInteger serviceStatusCode;

@property(nonatomic, copy) NSString *responseJsonResult;

/**
 *  初始化数据
 *
 *  @param nsdata
 *  @param needDecrypt
 *
 *  @return
 */
- (instancetype)initWithData:(NSData *)nsdata
                            :(BOOL)needDecrypt;

- (instancetype)initWithData:(NSData *)nsdata
                            :(BOOL)needDecrypt
                            :(NSString *)decryptKey;

- (NSString *)getResponseJson;

// TODO Useless Method
- (NSData *)memberOfData:(NSData *)object;

@end
