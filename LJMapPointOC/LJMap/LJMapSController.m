//
//  LJMapSController.m
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/7.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "LJMapSController.h"
#import "LJSearchMapController.h"

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

@property (nonatomic, copy) NSArray<LJMapPlace *> *places;

@end

@implementation LJMapSController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self setupMap];
    
}

- (void)setupMap {
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(26.0, 119.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
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
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.isUserLocation) {
        CLLocationCoordinate2D center = userLocation.location.coordinate;
        [mapView setCenterCoordinate:center animated:YES];
        self.isUserLocation = YES;
    }
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
            self.places = places;
            [self.tableView reloadData];
            [self.activityIView stopAnimating];
        }];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"LJAnnotationViewCurrent"];
    if (!annView) {
        annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LJAnnotationViewCurrent"];
    }
    annView.annotation = annotation;
    
    CLLocationCoordinate2D currCoord = annotation.coordinate;
    CLLocationCoordinate2D userCoord = mapView.userLocation.coordinate;
    if (currCoord.latitude == userCoord.latitude && currCoord.longitude == userCoord.longitude) {
        
    } else {
        annView.image = [UIImage imageNamed:@"fav_fileicon_loc90"];
    }
    return annView;
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
    return cell;
}

#pragma mark - LJSearchMapControllerDelegate

- (void)searchMapController:(LJSearchMapController *)controller didFinishSeleted:(LJMapPlace *)place {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(place.latitude, place.longitude);
    [self.mapView setCenterCoordinate:coord animated:YES];
}

@end
