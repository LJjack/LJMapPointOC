//
//  LJSearchMapController.m
//  LJMapPointOC
//
//  Created by 刘俊杰 on 2017/3/8.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "LJSearchMapController.h"


@interface LJSearchMapController ()<UITextFieldDelegate,
UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray<LJMapPlace *> *places;

@end

@implementation LJSearchMapController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Search"]];
    self.searchField.leftView = imageView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;//此处用来设置leftview现实时机
    self.tableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.searchField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.searchField resignFirstResponder];
}

#pragma mark - Action

- (IBAction)clickBackBtn:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSearchBtn:(UIButton *)sender {
    [self searchMap];
    
}
- (IBAction)handleTapGR:(UITapGestureRecognizer *)sender {
    
    [self.searchField resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)handleTextFieldTextDidChangeNotification {
    self.searchBtn.enabled = self.searchField.text.length != 0;
}

#pragma mark - UITextFieldDelegate

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if ([self.delegate respondsToSelector:@selector(searchMapController:didFinishSeleted:)]) {
        [self.delegate searchMapController:self didFinishSeleted:self.places[indexPath.row]];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

#pragma mark - Private Method

- (void)searchMap {
    if (!self.searchField.text.length) return;
    [self.searchField resignFirstResponder];
    LJMapSearch *search = [[LJMapSearch alloc] initWithRegion:self.region query:self.searchField.text];
    
    [search startWithCompletionHandler:^(NSArray<LJMapPlace *> *places) {
        self.places = places;
        [self.tableView reloadData];
    }];
}

@end
