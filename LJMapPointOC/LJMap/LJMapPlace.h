//
//  LJMapPlace.h
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/17.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLPlacemark.h>
@interface LJMapPlace : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *detailName;

@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, assign) BOOL selected;

@end
