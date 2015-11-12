//
//  ALBBSSOResponseEntity.h
//  ALBBSSO
//
//  Created by yixiao on 15/7/1.
//  Copyright (c) 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ALBBSResponseCodeSuccess                = 200,        //成功
    ALBBSREsponseCodeTokenInvalid           = 400,        //授权用户token错误
    ALBBSResponseCodeBaned                  = 505,        //用户被封禁
    ALBBSResponseCodeArgALBBentsError       = 522,        //参数错误,提供的参数不符合要求
    ALBBSResponseCodeGetNoUidFromOauth      = 5020,       //授权之后没有得到用户uid
    ALBBSResponseCodeAccessTokenExpired     = 5027,       //token过期
    ALBBSResponseCodeNetworkError           = 5050,       //网络错误
    ALBBSResponseCodeGetProfileFailed       = 5051,       //获取账户失败
    ALBBSResponseCodeCancel                 = 5052,        //用户取消授权
    ALBBSResponseCodeGetOpenAccountFailed   = 5054,        //获取openaccount失败
} ALBBSResponseCode;

@interface ALBBSSOResponseEntity : NSObject

/**
 代表发送结果，ALBBSResponseCodeSuccess代表成功，参看上面的定义
 */
@property (nonatomic, assign) ALBBSResponseCode responseCode;

/**
 错误原因
 
 */
@property (nonatomic, strong) NSString *message;

/**
 返回数据
 
 */
@property (nonatomic, strong) NSDictionary *data;

/**
 客户端发送出现的错误
 
 */
@property (nonatomic, strong) NSError *error;


@end
