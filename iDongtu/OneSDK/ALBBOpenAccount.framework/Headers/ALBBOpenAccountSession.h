//
//  ALBBOpenAccountSession.h
//  ALBBOpenAccount
//
//  Created by zhoulai on 15/3/17.
//  Copyright (c) 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALBBOpenAccountUser.h"

@class ALBBOpenAccountSession;
typedef void (^ALBBOpenAccountStateChangeHandler)(ALBBOpenAccountSession *currentSession);

@interface ALBBOpenAccountSession : NSObject

+ (ALBBOpenAccountSession *)sharedInstance;
#pragma -mark

/**
 *  帐号登录态切换时的监听处理器
 *
 *  @param handler description
 */
-(void) addOpenAccountStateChangeHandler:(ALBBOpenAccountStateChangeHandler)handler;
/**
 *  是否已有帐号登录
 *
 *  @return return value description
 */
-(BOOL) isLogin;

/**
 *  返回已经登录的帐号
 */
-(ALBBOpenAccountUser *) getUser;



/**
 *  注销当前已登录的帐号
 */
-(void)logout;


-(NSString *)getAuthToken;


@end
