//
//  CrossfadeTransaction.m
//  iTestDynamic
//
//  Created by Bernardo Breder on 04/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "CrossfadeTransaction.h"

@implementation CrossfadeTransaction

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromVC.view.frame = [transitionContext initialFrameForViewController:fromVC];
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    [transitionContext.containerView addSubview:fromVC.view];
    [transitionContext.containerView addSubview:toVC.view];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    toVC.view.alpha = 0.0;
    [UIView animateWithDuration:duration animations:^{
        toVC.view.alpha = 1.0;
        fromVC.view.alpha = 0.0;
    } completion:^(BOOL finished){
        fromVC.view.alpha = 1.0;
        [transitionContext completeTransition:YES];
    }];
}

@end
