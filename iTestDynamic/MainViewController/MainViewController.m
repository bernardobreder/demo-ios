//
//  MainViewController.m
//  iTestDynamic
//
//  Created by Bernardo Breder on 04/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "MainViewController.h"
#import "PopViewController.h"
#import "CrossfadeTransaction.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Push" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onPushAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:50]];
    }
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Red" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onRedAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0/3 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:50]];
    }
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Green" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onGreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0/3 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:50]];
    }
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Yellow" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onBlueAction:) forControlEvents:UIControlEventTouchUpInside];
        //            cancelButton.backgroundColor = [UIColor redColor];
        [self.view addSubview:button];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0/3 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:50]];
    }
}


#pragma mark - Actions

- (void)onPushAction:(UIButton*)button
{
    PopViewController* controller = [[PopViewController alloc] init];
    controller.transitioningDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)onRedAction:(UIButton*)button
{
    [UIView beginAnimations:Nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.view.backgroundColor = [UIColor redColor];
    [UIView commitAnimations];
}

- (void)onGreenAction:(UIButton*)button
{
    [UIView beginAnimations:Nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.view.backgroundColor = [UIColor greenColor];
    [UIView commitAnimations];
}

- (void)onBlueAction:(UIButton*)button
{
    [UIView beginAnimations:Nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.view.backgroundColor = [UIColor yellowColor];
    [UIView commitAnimations];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[CrossfadeTransaction alloc] init];
}

@end
