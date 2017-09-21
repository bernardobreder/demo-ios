//
//  UIMainViewController.h
//  iPortableApp
//
//  Created by Bernardo Breder on 07/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGenericViewController.h"

@interface UIMainViewController : UIGenericViewController

@property (nonatomic, strong) UIView* bodyView;
@property (nonatomic, strong) UIView* northView;
@property (nonatomic, strong) UIScrollView* centerView;
@property (nonatomic, strong) UIView* centerContentView;
@property (nonatomic, strong) UIView* southView;

@end
