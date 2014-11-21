//
//  ViewController.m
//  Demo_PanGesture
//
//  Created by Tongtong Xu on 14/11/21.
//  Copyright (c) 2014年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "NormalViewController.h"
#import "TTXTransition.h"
#import "ScrollViewController.h"

@implementation NormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNext)]];
}

- (void)showNext
{
    ScrollViewController *v = [[ScrollViewController alloc] init];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld",(long)self.navigationController.viewControllers.count];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end
