//
//  UIMainViewController.m
//  iPortableApp
//
//  Created by Bernardo Breder on 07/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "UIMainViewController.h"
#import "UIViewController+Size.h"
#import "UIGenericViewController.h"

@interface UIMainViewController ()

@end

@implementation UIMainViewController

@synthesize bodyView;
@synthesize northView;
@synthesize centerView;
@synthesize centerContentView;
@synthesize southView;

- (void)loadView
{
    self.view = [[UIView alloc] init];
    {
        bodyView = [[UIView alloc] init];
        bodyView.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:bodyView];
    }
    {
        northView = [[UIView alloc] init];
        northView.backgroundColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:1.0];
        [self.view addSubview:northView];
    }
    {
        centerView = [[UIScrollView alloc] init];
        centerView.backgroundColor = [UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:1.0];
        centerView.pagingEnabled = true;
        [self.view addSubview:centerView];
    }
    {
        southView = [[UIView alloc] init];
        southView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:1.0];
        [self.view addSubview:southView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    {
        centerContentView = [[UIView alloc] init];
        for (int n = 0; n < 10 ; n++) {
            UILabel* view = [[UILabel alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view.text = [NSString stringWithFormat:@"%d", (n+1)];
            view.textAlignment = NSTextAlignmentCenter;
            [centerContentView addSubview:view];
        }
        [centerView addSubview:centerContentView];
    }
}

- (void)layoutSubviewsFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    bodyView.frame = toRect;
    northView.frame = CGRectMake(0, 0, toRect.size.width, 70);
    centerView.frame = CGRectMake(0, 70, toRect.size.width, toRect.size.height - 70 - 50);
    southView.frame = CGRectMake(0, toRect.size.height - 50, toRect.size.width, 50);
    centerContentView.frame = CGRectMake(0, 0, centerContentView.subviews.count * toRect.size.width, centerView.frame.size.height);
    centerView.contentSize = centerContentView.frame.size;
    for (int n = 0; n < centerContentView.subviews.count ; n++) {
        UIView* view = centerContentView.subviews[n];
        view.frame = CGRectMake(n * centerView.frame.size.width, 0, centerView.frame.size.width, centerView.frame.size.height);
    }
    centerView.contentOffset = CGPointMake(floor(centerView.contentOffset.x / fromRect.size.width) * toRect.size.width, 0);
}

@end
