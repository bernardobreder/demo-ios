//
//  UIMainViewController.m
//  IRowTableView
//
//  Created by Bernardo Breder on 05/09/14.
//  Copyright (c) 2014 Breder Organization. All rights reserved.
//

#import "UIMainViewController.h"

@interface UIMainViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *navigatorView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *backImage;

@end

@implementation UIMainViewController

@synthesize tableView = _tableView;
@synthesize navigatorView = _navigatorView;
@synthesize backButton = _backButton;
@synthesize titleLabel = _titleLabel;
@synthesize backImage = _backImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	CGSize size = self.view.bounds.size;
	{
		_backImage = [UIImage imageNamed:@"back.png"];
	}
	{
		_navigatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 70)];
		_navigatorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		_navigatorView.layer.shadowOpacity = 0.5;
		_navigatorView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
		[self.view addSubview:_navigatorView];
	}
	{
		_backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 50)];
		[_backButton setImage:_backImage forState:UIControlStateNormal];
		[_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_backButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateHighlighted];
		[_backButton setImageEdgeInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
		[self.view addSubview:_backButton];
	}
	{
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, size.width, 50)];
		_titleLabel.text = @"Cenário";
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
		[self.view addSubview:_titleLabel];
	}
	{
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, size.width, size.height - 70)];
		_tableView.dataSource = self;
		_tableView.delegate = self;
        _tableView.rowHeight = 44;
        _tableView.sectionHeaderHeight = 50;
//        _tableView.estimatedSectionHeaderHeight = 50;
		_tableView.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_tableView];
	}
	{
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, MAX(size.width, size.height), MAX(size.width, size.height));
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.7 green:0.7 blue:0.8 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.2 green:0.2 blue:0.5 alpha:1.0] CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"1";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"Head";
    UILabel *cell = [[UILabel alloc] init];
	cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    cell.text = [NSString stringWithFormat:@"Header %ld", section];
	return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSNumber* data = [NSNumber numberWithInt:indexPath.row];
	cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", [data intValue]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

@end
