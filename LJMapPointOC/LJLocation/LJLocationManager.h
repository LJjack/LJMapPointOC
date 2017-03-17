//
//  LJLocationManager.h
//  testRoundPlace
//
//  Created by 刘俊杰 on 16/9/2.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import <CoreLocation/CLPlacemark.h>

#import "LJAlertLocation.h"

typedef void(^LJLocationManagerDidUpdateBlock)(double latitude,double longitude);
typedef void(^LJLocationManagerDidFailBlock)(NSError *error);

@interface LJLocationManager : NSObject

@property (nonatomic, assign) double latitude;//纬度

@property (nonatomic, assign) double longitude;//经度

+ (instancetype)sharedManager;
/**
 *  判断是否能够定位
 */
- (BOOL)judgeCanLocation;

/**
 根据经纬度反向地理编译出地址信息
 
 @param completionHandler 结果 block
 */
-(void)reverseGeocodeCompletionHandler:(void(^)(CLPlacemark *placemark))completionHandler;

/**
 *  根据经纬度反向地理编译出地址信息
 *
 *  @param latitude          纬度
 *  @param longitude         经度
 *  @param completionHandler 结果 block
 */
-(void)reverseGeocodeWithLatitude:(double)latitude
                        longitude:(double)longitude
                completionHandler:(void(^)(CLPlacemark *placemark))completionHandler;

/**
 *  开始定位
 */
- (void)startUpdateLocation;
/**
 *  停止定位
 */
- (void)stopUpdateLocation;

/**
 开始方向
 */
- (void)startUpdatingHeading;

/**
 开始方向
 */
- (void)stopUpdatingHeading;

@end
