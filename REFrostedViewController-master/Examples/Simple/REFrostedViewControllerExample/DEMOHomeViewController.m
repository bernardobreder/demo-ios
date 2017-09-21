//
//  DEMOHomeViewController.m
//  REFrostedViewControllerExample
//
//  Created by Roman Efimov on 9/18/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "DEMOHomeViewController.h"
#import "DEMONavigationController.h"
#import "UITrackingModeButton.h"

@interface DEMOHomeViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray* balanceColorArray;
@property (nonatomic, strong) NSArray* balanceHeaderColorArray;
@property (nonatomic, strong) NSArray* balanceArray;
@property (nonatomic, strong) NSArray* productArray;
@property (nonatomic, strong) NSArray* indexArray;

@property (nonatomic, strong) UITrackingModeButton *forecastButton;
@property (nonatomic, strong) UITrackingModeButton *accomplishedButton;
@property (nonatomic, strong) UITrackingModeButton *toBeAccomplishedButton;
@property (nonatomic, strong) UITrackingModeButton *linearForecastButton;
@property (nonatomic, strong) UITrackingModeButton *deviationButton;

@property (nonatomic, strong) UIImage *productImage;
@property (nonatomic, strong) UIImage *productSetImage;
@property (nonatomic, strong) UIImage *balanceImage;
@property (nonatomic, strong) UIImage *balanceSetImage;

@property (nonatomic, strong) NSArray *menuHeaderArray;
@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, strong) NSArray *monthArray;

@end

@implementation DEMOHomeViewController

@synthesize tableView = _tableView;
@synthesize productSetImage;
@synthesize productImage;
@synthesize balanceSetImage;
@synthesize balanceImage;
@synthesize balanceColorArray;
@synthesize balanceHeaderColorArray;
@synthesize balanceArray;
@synthesize productArray;
@synthesize indexArray;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Cenário Jan 2008";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:(DEMONavigationController *)self.navigationController action:@selector(showMenu)];
	{
		_tableView = [[UITableView alloc] initWithFrame:self.view.frame];
		_tableView.dataSource = self;
		_tableView.delegate = self;
		[self.view addSubview:_tableView];
	}
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    imageView.image = [UIImage imageNamed:@"Balloon"];
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self.view addSubview:imageView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == menuTableView) {
        return [self numberOfSectionsInMenuTableView:menuTableView];
    } else {
        return balanceArray.count;
    }
}

- (NSInteger)numberOfSectionsInMenuTableView:(UITableView *)tableView
{
    return menuHeaderArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == menuTableView) {
        return [self menuTableView:menuTableView numberOfRowsInSection:section];
    } else {
        return productArray.count;
    }
}

- (NSInteger)menuTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)menuArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == menuTableView) {
        return [self menuTableView:menuTableView cellForRowAtIndexPath:indexPath];
    } else {
        return [self dataTableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)menuTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"MenuCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];
		cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Light" size:14];
    }
	cell.backgroundColor = balanceColorArray[indexPath.section % balanceColorArray.count];
	cell.imageView.image = productImage;
	cell.textLabel.text = menuArray[indexPath.section][indexPath.row];
    return cell;
}

- (UITableViewCell *)dataTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DataCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DataCell"];
		cell.textLabel.font = [UIFont fontWithName:@"Courier" size:18];
		cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:18];
    }
	cell.backgroundColor = balanceColorArray[indexPath.section % balanceColorArray.count];
	cell.imageView.image = productSetImage;
	{
        if (random() % 2 == 0) {
			cell.imageView.image = productImage;
        } else {
			cell.imageView.image = productSetImage;
        }
    }
	cell.textLabel.text = productArray[indexPath.row];
    {
        long r = random();
        if (r % 3 == 0) {
            cell.detailTextLabel.text = @"";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", ((int)r % 200)];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == menuTableView) {
        return [self menuTableView:menuTableView viewForHeaderInSection:section];
    } else {
        for (int n = 0; n < dataTableView.count ; n++) {
            if (dataTableView[n] == tableView) {
                return [self dataTableView:tableView viewForHeaderInSection:section tableIndex:n];
            }
        }
        return nil;
    }
}

- (UIView *)menuTableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuHeaderCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MenuHeaderCell"];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:14.0];
		cell.contentView.backgroundColor = balanceHeaderColorArray[section % balanceHeaderColorArray.count];
	}
    cell.textLabel.text = menuHeaderArray[section];
    return cell;
}

- (UIView *)dataTableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section tableIndex:(NSInteger)tableIndex
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataHeaderCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DataHeaderCell"];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.font = [UIFont fontWithName:@"Courier-Bold" size:14.0];
		cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:12.0];
		cell.contentView.backgroundColor = balanceHeaderColorArray[section % balanceHeaderColorArray.count];
	}
    cell.imageView.image = balanceSetImage;
	cell.textLabel.text = balanceArray[section];
	cell.detailTextLabel.text = monthArray[tableIndex];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	//	return indexArray;
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == menuTableView) {
        [self tableView:menuTableView didSelectRowAtIndexPath:indexPath];
    } else {
        for (int n = 0; n < dataTableView.count ; n++) {
            if (dataTableView[n] == tableView) {
                [self tableView:tableView didSelectRowAtIndexPath:indexPath atIndex:n];
				break;
            }
        }
    }
}

@end
