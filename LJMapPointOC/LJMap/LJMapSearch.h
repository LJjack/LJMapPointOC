//
//  LJMapSearch.h
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/7.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LJMapPlace.h"

@interface LJMapTool : NSObject

+ (LJMapPlace *)placemarkToMapPlace:(CLPlacemark *)placemark;

@end

@interface LJMapSearch : NSObject

- (instancetype)initWithRegion:(MKCoordinateRegion)region query:(NSString *)query;

- (void)startWithCompletionHandler:(void(^)(NSArray<LJMapPlace *> *places))handler;

@end



