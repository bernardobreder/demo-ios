//
//  BandeiraViewController.m
//  iSchoolChapter1
//
//  Created by Bernardo Breder on 31/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "BandeiraViewController.h"

@interface BandeiraViewController ()

@end

@implementation BandeiraViewController

#pragma mark - Create

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self onSliderChanged:nil];
}

#pragma mark - Action

- (IBAction)onButton1Touch:(id)sender
{
    NSLog(@"Button1");
    [UIView animateWithDuration:0.5 animations:^{
        [self.slider setValue:0.2 animated:YES];
    }];
    [self onSliderChanged:nil];
}

- (IBAction)onButton2Touch:(id)sender
{
    NSLog(@"Button2");
    [UIView animateWithDuration:0.5 animations:^{
        [self.slider setValue:0.8 animated:YES];
    }];
    [self onSliderChanged:nil];
}

- (IBAction)onSliderChanged:(id)sender
{
    self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", self.slider.value * 100];
}

@end
