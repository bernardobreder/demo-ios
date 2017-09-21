//
//  MotionViewController.m
//  iTestMotion
//
//  Created by Bernardo Breder on 04/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "MotionViewController.h"

@interface MotionViewController ()

@end

@implementation MotionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    int max = 20;
    double width = self.view.frame.size.width;
    for (int n = 0 ; n < max ; n++) {
        double div = ((width - 40)/max) / 2;
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(10+n*div, 10+n*div, width-20-n*2*div, width-20-n*2*div)];
        view.backgroundColor = [UIColor colorWithRed:1.0-n*(1.0/max) green:0.0 blue:0.0 alpha:1.0];
        [self.view addSubview:view];
        {
            UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            xAxis.minimumRelativeValue = @(-10*n);
            xAxis.maximumRelativeValue = @(10*n);
            UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            yAxis.minimumRelativeValue = @(-10*n);
            yAxis.maximumRelativeValue = @(10*n);
            UIMotionEffectGroup* group = [[UIMotionEffectGroup alloc] init];
            group.motionEffects = @[xAxis, yAxis];
            [view addMotionEffect:group];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
