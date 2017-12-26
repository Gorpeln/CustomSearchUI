//
//  GPSearchConst.h
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIView+GPAdditions.h"
#import "UIColor+GPAdditions.h"

#define GPSEARCH_MARGIN 10
#define GPSEARCH_BACKGROUND_COLOR GPSEARCH_COLOR(255, 255, 255)
#define GPRandomColor [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1.0];


#ifdef DEBUG
#define GPSEARCH_LOG(...) NSLog(__VA_ARGS__)
#else
#define GPSEARCH_LOG(...)
#endif

#define GPSEARCH_COLOR(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define GPSEARCH_RANDOM_COLOR  GPSEARCH_COLOR(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

#define GPSEARCH_DEPRECATED(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#define GPSEARCH_REALY_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define GPSEARCH_REALY_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define GPScreenW (GPSEARCH_REALY_SCREEN_WIDTH < GPSEARCH_REALY_SCREEN_HEIGHT ? GPSEARCH_REALY_SCREEN_WIDTH : GPSEARCH_REALY_SCREEN_HEIGHT)
#define GPScreenH (GPSEARCH_REALY_SCREEN_WIDTH > GPSEARCH_REALY_SCREEN_HEIGHT ? GPSEARCH_REALY_SCREEN_WIDTH : GPSEARCH_REALY_SCREEN_HEIGHT)
#define GPSEARCH_SCREEN_SIZE CGSizeMake(GPScreenW, GPScreenH)

#define GPSEARCH_SEARCH_HISTORY_CACHE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"GPSearchhistories.plist"] // the path of search record cached

UIKIT_EXTERN NSString *const GPSearchSearchPlaceholderText;
UIKIT_EXTERN NSString *const GPSearchHotSearchText;
UIKIT_EXTERN NSString *const GPSearchSearchHistoryText;
UIKIT_EXTERN NSString *const GPSearchEmptySearchHistoryText;
UIKIT_EXTERN NSString *const GPSearchEmptyButtonText;
UIKIT_EXTERN NSString *const GPSearchEmptySearchHistoryLogText;
UIKIT_EXTERN NSString *const GPSearchCancelButtonText;
