//
//  MainViewController.m
//  iSampleTableViewEdit
//
//  Created by Bernardo Breder on 16/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* addButton;
@property (nonatomic, strong) UIButton* editButton;
@property (nonatomic, strong) NSMutableArray* array;

@end

@implementation MainViewController

@synthesize tableView;
@synthesize addButton;
@synthesize editButton;
@synthesize array;

- (void)loadView
{
    array = [[NSMutableArray alloc] init];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 70)];
        view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [self.view addSubview:view];
        {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, size.width/3, 50)];
            [button setTitle:@"Add" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onAddAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
        {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(size.width/3, 20, size.width/3, 50)];
            [button setTitle:@"Delete" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
        {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(size.width/3*2, 20, size.width/3, 50)];
            [button setTitle:@"Edit" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onEditAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
    }
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, size.width, size.height - 70)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.allowsSelectionDuringEditing = true;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.view addSubview:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    NSNumber* data = array[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Line %d", [data intValue]];
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [array removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.row == destinationIndexPath.row) return;
    {
        NSNumber* sourceData = [array objectAtIndex:sourceIndexPath.row];
        [array removeObjectAtIndex:sourceIndexPath.row];
        [array insertObject:sourceData atIndex:(destinationIndexPath.row)];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected");
    if ([self.tableView isEditing]) {
        static NSInteger counter = 10;
        NSInteger row = indexPath.row;
        NSNumber* value = [NSNumber numberWithInt:++counter];
        array[row] = value;
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView endUpdates];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

- (void)onAddAction:(UIButton*)button
{
    NSNumber* value = [NSNumber numberWithInt:array.count+1];
    [array addObject:value];
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(array.count-1) inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [tableView endUpdates];
}

- (void)onDeleteAction:(UIButton*)button
{
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil) {
        return;
    }
    [array removeObjectAtIndex:indexPath.row];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [tableView endUpdates];
    if (indexPath.row < array.count) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)onEditAction:(UIButton*)button
{
    if ([tableView isEditing]) {
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [button setTitleColor:([UIColor blueColor]) forState:UIControlStateNormal];
        [self setEditing:NO animated:YES];
        [tableView setEditing:NO animated:YES];
    } else {
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:([UIColor redColor]) forState:UIControlStateNormal];
        [self setEditing:YES animated:YES];
        [tableView setEditing:YES animated:YES];
    }
}

@end
