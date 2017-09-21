//
//  MainViewController.m
//  iDynamic
//
//  Created by Bernardo Breder on 02/09/14.
//  Copyright (c) 2014 Breder Organization. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	CGSize size = self.view.bounds.size;
	{
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = CGRectMake(0, 0, MAX(size.width, size.height), MAX(size.width, size.height));
		gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.5 green:0.5 blue:0.8 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.5 alpha:1.0] CGColor], nil];
		[self.view.layer insertSublayer:gradient atIndex:0];
	}
	{
		UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
		tableView.backgroundColor = [UIColor clearColor];
		tableView.dataSource = self;
		self.contentView = tableView;
		self.menuMinHeight = 40;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.text = [NSString stringWithFormat:@"Line %d", indexPath.row];
	return cell;
}

@end
