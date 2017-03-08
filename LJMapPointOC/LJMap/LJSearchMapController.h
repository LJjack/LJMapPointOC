//
//  LJSearchMapController.h
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/8.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJMapSearch.h"

@class LJSearchMapController;

@protocol LJSearchMapControllerDelegate <NSObject>

- (void)searchMapController:(LJSearchMapController *)controller didFinishSeleted:(LJMapPlace *)place;

@end

@interface LJSearchMapController : UIViewController

@property (nonatomic, assign) MKCoordinateRegion region;

@property (nonatomic, weak) id<LJSearchMapControllerDelegate> delegate;

@end
