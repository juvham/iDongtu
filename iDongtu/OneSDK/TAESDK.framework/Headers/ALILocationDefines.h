//
//  ALILocationDefines.h
//  TAESDK
//
//  Created by madding.lip on 3/16/15.
//  Copyright (c) 2015 alibaba. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>

#define kALIHorizontalAccuracyThresholdCity            5000.0  // in meters
#define kALIHorizontalAccuracyThresholdNeighborhood    1000.0  // in meters
#define kALIHorizontalAccuracyThresholdBlock           100.0   // in meters
#define kALIHorizontalAccuracyThresholdHouse           15.0    // in meters
#define kALIHorizontalAccuracyThresholdRoom            5.0     // in meters

#define kALIUpdateTimeStaleThresholdCity               600.0   // in seconds
#define kALIUpdateTimeStaleThresholdNeighborhood       300.0   // in seconds
#define kALIUpdateTimeStaleThresholdBlock              60.0    // in seconds
#define kALIUpdateTimeStaleThresholdHouse              15.0    // in seconds
#define kALIUpdateTimeStaleThresholdRoom               5.0     // in seconds


// 定位精度枚举类
typedef NS_ENUM(NSInteger, ALILocationAccuracy) {
    
    ALILocationAccuracyNone = 0,     // 无效定位精度 (>5000m, received >10 minutes ago)
    ALILocationAccuracyCity,         // 定位精度 <= 5000m, 10 minutes -- lowest accuracy
    ALILocationAccuracyNeighborhood, // 定位精度 <= 1000m, 5 minutes
    ALILocationAccuracyBlock,        // 定位精度 <= 100m, 60 seconds
    ALILocationAccuracyHouse,        // 定位精度 <= 15m, 15 seconds
    ALILocationAccuracyRoom,         // 定位精度 <= 5m, 5 seconds
};

// 定位返回状态
typedef NS_ENUM(NSInteger, ALILocationStatus) {
    ALILocationStatusSuccess = 0,           // 获取指定定位成功
    ALILocationStatusTimedOut,              // 定位成功，但是非目标精度
    ALILocationStatusNotDetermined,         // 用户对定位授权无响应
    ALILocationStatusDenied,                // 用户拒绝app使用定位
    ALILocationStatusRestricted,            // 系统配置约束 限制获取定位
    ALILocationStatusDisabled,              // 用户关闭了定位服务
    ALILocationStatusError                  // 系统定位服务出错
};


/**
 * 定位请求回调，返回各种结果
 * @param currentLocation 最新一次定位结果；
 * @param accuracy 实际定位精度
 * @param status 定位状态，知名定位的最终结果
 */
typedef void(^ALILocationCallback)(CLLocation *currentLocation, ALILocationAccuracy accuracy, ALILocationStatus status);
