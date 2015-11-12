//
//  ALBBOpenAccountService.h
//  ALBBOpenAccount
//
//  Created by zhoulai on 15/4/3.
//  Copyright (c) 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALBBOpenAccountSession;

typedef void (^ALBBOpenAccountSuccessCallback)(ALBBOpenAccountSession *currentSession);
typedef void (^ALBBOpenAccountFailedCallback)(NSError *error);

@protocol ALBBOpenAccountService <NSObject>

/**
 *  根据authToken获取登录态
 *
 *  @param authToken       <#authToken description#>
 *  @param successCallback <#successCallback description#>
 *  @param failedCallback  <#failedCallback description#>
 */
- (void)loginByAuthToken:(NSString *)authToken
         successCallback:(ALBBOpenAccountSuccessCallback)successCallback
          failedCallback:(ALBBOpenAccountFailedCallback)failedCallback;

/**
 *  根据二次验证token获取登录态
 *
 *  @param token           二次验证token
 *  @param successCallback 成功回调
 *  @param failedCallback  失败回调
 */
- (void)loginByTokenAfterDoubleCheck:(NSString *)token
                     successCallback:(ALBBOpenAccountSuccessCallback)successCallback
                      failedCallback:(ALBBOpenAccountFailedCallback)failedCallback;

/**
 *  重置openaccount的数据
 */
- (void)resetData;

@end
