//
//  ALBBOpenAccountSSOPluginServiceProtocol.h
//  ALBBOpenAccountSSOPluginAdapter
//
//  Created by 友和(lai.zhoul@alibaba-inc.com) on 14/11/26.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALBBSSOResponseEntity.h"
#import <ALBBOpenAccount/ALBBOpenAccountSDK.h>

typedef NS_ENUM(NSInteger, ALBBSSOType) {
    ALBBSSOTypeTAOBAO   = 1,
    ALBBSSOTypeWEIXIN,
    ALBBSSOTypeWEIBO,
    ALBBSSOTypeQQ
};

typedef void (^ALBBSocialDataServiceCompletion)(ALBBSSOResponseEntity * response,ALBBOpenAccountSession *session);

@protocol ALBBOpenAccountSSOServiceProtocol <NSObject>

- (void)ssoWithPlatForm:(ALBBSSOType)sType
          presentingVC:(UIViewController *)presentingController
               present:(BOOL)ispresent
            completion:(ALBBSocialDataServiceCompletion)completion;

- (void)setWXAppId:(NSString *)appId appSecret:(NSString *)appSecret url:(NSString *)url;
- (void)setQQWithAppId:(NSString *)appId appKey:(NSString *)appKey url:(NSString *)url;
- (void)setWBAppKey:(NSString *)appKey appSecret:(NSString *)appSecret url:(NSString *)url;
@end
