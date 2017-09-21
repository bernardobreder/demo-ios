//
//  MainViewController.m
//  iNavegation
//
//  Created by Bernardo Breder on 16/06/14.
//  Copyright (c) 2014 Breder Organization. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	int width = self.view.frame.size.width;
	int height = self.view.frame.size.height;
	{
		UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height) style:UITableViewStylePlain];
		tableView.dataSource = self;
		tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
		[self.view addSubview:tableView];
	}
	{
		UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
		navigationBar.alpha = 0.8;
		[self.view addSubview:navigationBar];
		{
			UINavigationItem *navItem = [[UINavigationItem alloc] init];
			navItem.title = @"Navigation Bar title here";
			UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:nil];
			navItem.leftBarButtonItem = leftButton;
			UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:nil];
			navItem.rightBarButtonItem = rightButton;
			navigationBar.items = @[ navItem ];
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1024;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	cell.textLabel.text = [NSNumber numberWithInt:indexPath.row].description;
	return cell;
}

@end
