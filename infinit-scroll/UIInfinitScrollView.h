//
//  InfinitScrollView.h
//  scroll
//
//  Created by Bernardo Breder on 15/02/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIInfinitScrollView.h"

@protocol UIInfinitScrollViewDelegate

@required

//- (NSInteger)pageView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UIView *)pageView:(id)infinitScrollView atPage:(int)pageIndex withRect:(CGRect)rect;

@optional

@end

@interface UIInfinitScrollView : UIScrollView <UIScrollViewDelegate> {
    NSMutableArray* views;
    int page;
}

@property(nonatomic, strong) IBOutlet id<UIInfinitScrollViewDelegate> model;

@property(nonatomic, assign) bool needToReload;

- (id)initWithCoder:(NSCoder *)inCoder;

- (void)layoutSubviews;

- (void)reloadData;

- (void)fireDataChanged;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end