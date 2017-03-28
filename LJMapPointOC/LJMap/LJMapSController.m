//
//  LJMapSController.m
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/7.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "LJMapSController.h"
#import "LJSearchMapController.h"
#import "LJLocationManager.h"

@interface LJAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

@implementation LJAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D) coordinate {
    if (self = [super init]) {
        self.coordinate = coordinate;
    }
    return self;
}

@end

@interface LJMapSController ()< MKMapViewDelegate,
UITableViewDelegate, UITableViewDataSource,
LJSearchMapControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIImageView *favImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIView;


@property (assign, nonatomic) BOOL isUserLocation;

@property (strong, nonatomic) LJAnnotation *currentAnnotation;

@property (copy,   nonatomic) NSArray<LJMapPlace *> *places;

@property (strong, nonatomic) UITableViewCell *selectedCell;

@property (strong, nonatomic) MKAnnotationView *userAnnotationView;

@end


static NSString *annotationIdentifier = @"LJAnnotationViewCurrent";
static NSString *userAnnotationIdentifier = @"LJUserAnnotationViewCurrent";

@implementation LJMapSController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self setupMap];
}

- (void)setupMap {
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.mapView.showsCompass = YES;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(26.0, 119.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    self.mapView.region = MKCoordinateRegionMake(center, span);
    
    //添加大头针
    self.currentAnnotation = [[LJAnnotation alloc] initWithCoordinate:center];
    [self.mapView addAnnotation:self.currentAnnotation];
}

#pragma mark - Action 

- (IBAction)clickSearchBtn:(UIBarButtonItem *)sender {
    LJSearchMapController *searchC = [self.storyboard instantiateViewControllerWithIdentifier:@"LJSearchMapController"];
    searchC.delegate = self;
    searchC.region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.navigationController pushViewController:searchC animated:YES];
}

- (IBAction)clickSureItem:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(mapSController:didSelecedPlace:)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self.selectedCell];
        LJMapPlace *place = self.places[indexPath.row];
        [self.delegate mapSController:self didSelecedPlace:place];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!self.isUserLocation) {
        CLLocationCoordinate2D center = userLocation.location.coordinate;
        mapView.centerCoordinate = center;
        self.currentAnnotation.coordinate = center;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isUserLocation = YES;
            [[LJLocationManager sharedManager] reverseGeocodeWithLatitude:center.latitude longitude:center.longitude completionHandler:^(CLPlacemark *placemark) {
                
                
                
            }];
            
            
        });
    }
    
    if (self.userAnnotationView) {
        [self rotateWithAnnotationView:self.userAnnotationView heading:userLocation.heading];
    }
    
}

- (void)rotateWithAnnotationView:(MKAnnotationView *)annotationView heading:(CLHeading *)heading {
    //将设备的方向角度换算成弧度
    double head = M_PI * heading.magneticHeading / 180.0;
    //创建不断旋转CALayer的transform属性的动画
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    //动画起始值
    CATransform3D formValue = annotationView.layer.transform;
    rotateAnimation.fromValue = [NSValue valueWithCATransform3D:formValue];
    //绕Z轴旋转heading弧度的变换矩阵
    CATransform3D toValue = CATransform3DMakeRotation(head, 0, 0, 1);
    //设置动画结束值
    rotateAnimation.toValue = [NSValue valueWithCATransform3D:toValue];
    rotateAnimation.duration = 0.35;
    rotateAnimation.removedOnCompletion = YES;
    //设置动画结束后layer的变换矩阵
    annotationView.layer.transform = toValue;
    
    //添加动画
    [annotationView.layer addAnimation:rotateAnimation forKey:nil];
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.favImageView.hidden = NO;
    if (self.currentAnnotation) {
        [mapView removeAnnotation:self.currentAnnotation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.favImageView.hidden = YES;
    
    if (self.currentAnnotation) {
        self.currentAnnotation.coordinate = mapView.centerCoordinate;
        [mapView addAnnotation:self.currentAnnotation];
        
        MKCoordinateRegion region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(0.00005, 0.00005));
        [self.activityIView startAnimating];
        LJMapSearch *search = [[LJMapSearch alloc] initWithRegion:region query:@"餐厅"];
        [search startWithCompletionHandler:^(NSArray<LJMapPlace *> *places) {
            CLLocationCoordinate2D coord = self.currentAnnotation.coordinate;
            [[LJLocationManager sharedManager] reverseGeocodeWithLatitude:coord.latitude longitude:coord.longitude completionHandler:^(CLPlacemark *placemark) {
                NSMutableArray *mArr = places.mutableCopy;
                LJMapPlace *fristModel = [LJMapTool placemarkToMapPlace:placemark];
                fristModel.selected = YES;
                [mArr insertObject:fristModel atIndex:0];
                self.places = mArr.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.activityIView stopAnimating];
                });
            }];
        }];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (mapView != self.mapView) return nil;
    
    if ([annotation isKindOfClass:[LJAnnotation class]]) {
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        annotationView.annotation = annotation;
        annotationView.image = [UIImage imageNamed:@"fav_fileicon_loc90"];
        return annotationView;
    } else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        MKAnnotationView *userAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userAnnotationIdentifier];
        if (!userAnnotationView) {
            userAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userAnnotationIdentifier];
        }
        userAnnotationView.annotation = annotation;
        userAnnotationView.image = [UIImage imageNamed:@"userAnnotation"];
        self.userAnnotationView = userAnnotationView;
        return userAnnotationView;
    }
    return nil;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJMapCell" forIndexPath:indexPath];
    LJMapPlace *model = self.places[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.detailName;
    if (model.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedCell = cell;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCell) {
        LJMapPlace *selecedModel = self.places[[tableView indexPathForCell:self.selectedCell].row];
        selecedModel.selected = NO;
        self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    LJMapPlace *model = self.places[indexPath.row];
    model.selected = YES;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedCell = cell;
}

#pragma mark - LJSearchMapControllerDelegate

- (void)searchMapController:(LJSearchMapController *)controller didFinishSeleted:(LJMapPlace *)place {
    CLLocationCoordinate2D coord = place.placemark.location.coordinate;
    [self.mapView setCenterCoordinate:coord animated:YES];
}

@end
