//
//  LJMapSController.h
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/7.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJMapPlace.h"
@class LJMapSController;

@protocol LJMapSControllerDelegate <NSObject>

@optional
- (void)mapSController:(LJMapSController *)controller didSelecedPlace:(LJMapPlace *)place;

@end

@interface LJMapSController : UIViewController

@property (nonatomic, weak) id<LJMapSControllerDelegate> delegate;

@end

