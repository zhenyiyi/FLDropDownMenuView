//
//  ViewController.m
//  FLDropDownMenuView
//
//  Created by fenglin on 7/7/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import "ViewController.h"
#import "FLDropDownMenuView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    NSArray *titles = @[@"首页", @"朋友圈", @"我的关注", @"明星", @"家人朋友"];
    FLDropDownMenuView *menuView = [[FLDropDownMenuView alloc] initWithFrame:CGRectMake(0, 0,100, 44) title:titles[0] items:titles];
    menuView.selectedAtIndex = ^(int index)
    {
        NSLog(@"selected title:%@", titles[index]);
    };
    menuView.width = [UIScreen mainScreen].bounds.size.width;
    self.navigationItem.titleView = menuView;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
