//
//  ALILocationService.h
//  TAESDK
//
//  Created by madding.lip on 3/16/15.
//  Copyright (c) 2015 alibaba. All rights reserved.
//

#ifndef TAESDK_ALILocationService_h
#define TAESDK_ALILocationService_h


#import "ALILocationDefines.h"


@interface ALILocationService : NSObject

+ (CLLocation *) getCurrentLocation;

+ (void) getCurrentLocation:(ALILocationCallback)callback;

+ (void) getCurrentLocation:(NSTimeInterval)timeout callback:(ALILocationCallback)callback;

@end

#endif
