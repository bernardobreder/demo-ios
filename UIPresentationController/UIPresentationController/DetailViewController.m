//
//  SecondViewController.m
//  UIPresentationController
//
//  Created by Bernardo Breder on 30/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
    CGSize size = self.view.frame.size;
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 50)];
        [button setTitle:@"Button 2" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onButton1Action:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)onButton1Action:(UIButton*)button
{
    
}

@end
