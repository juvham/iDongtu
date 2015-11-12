//
//  ALBBOpenAccountUser.h
//  ALBBOpenAccount
//
//  Created by zhoulai on 15/3/16.
//  Copyright (c) 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALBBOpenAccountUser : NSObject
@property (strong, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSString *displayName;
@property (copy, nonatomic, readonly) NSString *mobile;
@property (copy, nonatomic, readonly) NSString *loginId;
@property (copy, nonatomic, readonly) NSString *avatarUrl;
@property (copy, nonatomic, readonly) NSString *extInfos;//
@end
