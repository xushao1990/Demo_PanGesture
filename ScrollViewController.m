//
//  NViewController.m
//  ScrollView
//
//  Created by Tongtong Xu on 14/11/21.
//  Copyright (c) 2014年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "ScrollViewController.h"
#import "NormalViewController.h"
#import "TTXTransition.h"
#import "SwipeView.h"

@interface ScrollViewController ()<SwipeViewDataSource,SwipeViewDelegate>
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.items = [NSMutableArray array];
    for (int i = 0; i < 10; i++)
    {
        [_items addObject:@(i)];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    _swipeView = [[SwipeView alloc] initWithFrame:self.view.bounds];
    _swipeView.delegate = self;
    _swipeView.dataSource = self;
    _swipeView.pagingEnabled = YES;
    [self.view addSubview:self.swipeView];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [_items count];
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    NormalViewController *viewController = [[NormalViewController alloc] init];
    viewController.view.backgroundColor = [UIColor darkGrayColor];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    } else {
        label = (UILabel *)[view viewWithTag:1];
    }
    
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    label.text = [_items[index] stringValue];
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

@end
