//
//  CCPURLRequest.h
//  CloudPush
//
//  Created by wuxiang on 14-8-14.
//  Change by madding.lip at 2015.07.06
//  Copyright (c) 2014年 ___alibaba___. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  发起请求的一方
 */
@interface CCPURLRequest : NSObject
// 域名
@property(nonatomic, copy) NSString *domain;
// 会话标识
@property(nonatomic, copy) NSString *sid;
// 资源唯一标识
@property(nonatomic, copy) NSString *resource;
// 请求方式
@property(nonatomic, copy) NSString *method;
// 请求超时
@property(nonatomic) NSTimeInterval timeout;

@property(nonatomic, copy) NSString *version;
// 调用者版本
@property(nonatomic, copy) NSString *callerVersion;
// 加解密的key
@property(nonatomic, copy) NSString *codecKey;
// 序列化的类型（0：原始数据）
@property(nonatomic) UInt8 contentType;
// 资源类型
@property(nonatomic) UInt8 resouceType;
// 平台id
@property(nonatomic, copy) NSString *platformId;

// http请求头
@property(nonatomic, strong) NSMutableDictionary *heads;
// http请求参数
@property(nonatomic, strong) NSDictionary *params;

- (NSData *)encryptRequestData:(BOOL)needEncrypt;

// 无用的方法，可以考虑用property设置替代
- (void)setHTTPMethod:(NSString *)method;

@end
