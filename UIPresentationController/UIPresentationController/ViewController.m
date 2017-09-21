//
//  ViewController.m
//  UIPresentationController
//
//  Created by Bernardo Breder on 30/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize listViewController = _listViewController;
@synthesize detailViewController = _detailViewController;

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    
    return self;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listViewController = [[ListViewController alloc] init];
    [self addChildViewController:_listViewController];
    [self.view addSubview:_listViewController.view];
    
    _detailViewController = [[DetailViewController alloc] init];
    [self addChildViewController:_detailViewController];
    [self.view addSubview:_detailViewController.view];
    
    CGSize size = self.view.frame.size;
    _listViewController.view.frame = CGRectMake(0, 0, size.width / 3, size.height);
    _detailViewController.view.frame = CGRectMake(size.width / 3, 0, 2 * size.width / 3, size.height);
}

@end
