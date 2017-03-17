//
//  LJMapSearch.m
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/7.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "LJMapSearch.h"

@implementation LJMapTool

+ (LJMapPlace *)placemarkToMapPlace:(CLPlacemark *)placemark {
    LJMapPlace *model = [[LJMapPlace alloc] init];
    model.name = placemark.name;
    model.detailName = placemark.thoroughfare;
    model.placemark = placemark;
    return model;
}

@end

@interface LJMapSearch ()<MKLocalSearchCompleterDelegate>

@property (nonatomic, copy) NSString *query;

@property (nonatomic, assign) MKCoordinateRegion region;

@end

@implementation LJMapSearch

- (instancetype)initWithRegion:(MKCoordinateRegion)region query:(NSString *)query {
    if (self = [super init]) {
        self.region = region;
        self.query = query;
    }
    return self;
}

- (void)startWithCompletionHandler:(void(^)(NSArray<LJMapPlace *> *places))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.region = self.region;
        request.naturalLanguageQuery = self.query;
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
        [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"start  %@",error.localizedDescription);
            NSMutableArray *mArr = [NSMutableArray array];
            for (MKMapItem *item in response.mapItems) {
                if (!item.isCurrentLocation) {
                    LJMapPlace *model = [LJMapTool placemarkToMapPlace:item.placemark];
                    [mArr addObject:model];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler(mArr.copy);
            });
        }];
    });
}

@end
