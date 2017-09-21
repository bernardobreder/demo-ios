//
//  UIGenericViewController.m
//  iPortableApp
//
//  Created by Bernardo Breder on 07/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "UIGenericViewController.h"

@interface UIGenericViewController ()

@end

@implementation UIGenericViewController

- (void)layoutSubviewsFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [self viewDidAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect frame = self.view.frame;
    if ((frame.size.width < frame.size.height && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) || (frame.size.width > frame.size.height && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        CGFloat width = frame.size.width;
        frame.size.width = frame.size.height;
        frame.size.height = width;
    }
    [super viewDidAppear:animated];
    [self layoutSubviewsFromRect:frame toRect:frame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize fromSize = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? CGSizeMake(MAX(self.view.frame.size.width, self.view.frame.size.height), MIN(self.view.frame.size.width, self.view.frame.size.height)) : CGSizeMake(MIN(self.view.frame.size.width, self.view.frame.size.height), MAX(self.view.frame.size.width, self.view.frame.size.height));
    CGSize toSize = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? CGSizeMake(MIN(self.view.frame.size.width, self.view.frame.size.height), MAX(self.view.frame.size.width, self.view.frame.size.height)) : CGSizeMake(MAX(self.view.frame.size.width, self.view.frame.size.height), MIN(self.view.frame.size.width, self.view.frame.size.height));
    NSLog(@"WillAnimateRotate: %@", NSStringFromCGSize(toSize));
    [self layoutSubviewsFromRect:CGRectMake(0, 0, fromSize.width, fromSize.height) toRect:CGRectMake(0, 0, toSize.width, toSize.height)];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
