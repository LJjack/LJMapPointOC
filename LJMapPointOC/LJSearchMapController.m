//
//  LJSearchMapController.m
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/8.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "LJSearchMapController.h"
#import "LJMapSearch.h"

@interface LJSearchMapController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray<LJMapPlace *> *places;

@end

@implementation LJSearchMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Search"]];
    self.searchField.leftView = imageView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;//此处用来设置leftview现实时机
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Action

- (IBAction)clickBackBtn:(UIButton *)sender {
}

- (IBAction)clickSearchBtn:(UIButton *)sender {
    [self searchMap];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.searchBtn.enabled = range.location != 0;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchMap];
    return YES;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJSearchMapCell" forIndexPath:indexPath];
    LJMapPlace *model = self.places[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.detailName;
    return cell;
}

#pragma mark - Private Method

- (void)searchMap {
    LJMapSearch *search = [[LJMapSearch alloc] initWithRegion:self.region query:self.searchField.text];
    
    [search startWithCompletionHandler:^(NSArray<LJMapPlace *> *places) {
        self.places = places;
        [self.tableView reloadData];
    }];
}

@end
