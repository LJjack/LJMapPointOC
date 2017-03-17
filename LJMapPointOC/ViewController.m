//
//  ViewController.m
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/17.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "ViewController.h"
#import "LJMapSController.h"

@interface ViewController ()<LJMapSControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lngLabel;

@property (weak, nonatomic) IBOutlet UILabel *latLabel;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapSController:(LJMapSController *)controller didSelecedPlace:(LJMapPlace *)place {
    
    self.latLabel.text = [NSString stringWithFormat:@"%f",place.latitude];
    self.lngLabel.text = [NSString stringWithFormat:@"%f",place.longitude];
    self.cityLabel.text = place.name;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"openMapSController"]) {
        UINavigationController *navC = segue.destinationViewController;
        LJMapSController *mapC = (LJMapSController *)navC.topViewController;
        mapC.delegate = self;
    }
    
}


@end
