//
//  MainViewController.m
//  iSampleTableViewEdit
//
//  Created by Bernardo Breder on 16/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, strong) NSMutableArray* array;

@property (nonatomic, strong) NSMutableArray *filteredArray;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SearchViewController

@synthesize searchController = _searchController;

@synthesize tableView = _tableView;

@synthesize filteredArray = _filteredArray;

@synthesize searchBar = _searchBar;

@synthesize array = _array;

- (void)loadView
{
    _array = [[NSMutableArray alloc] init];
    for (NSInteger n = 0; n < 1024 ; n++) {
        [_array addObject:([[NSNumber numberWithInt:n] description])];
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, size.width, size.height - 50)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, size.width, 50)];
        _searchBar.delegate = self;
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.keyboardType = UIKeyboardTypeAlphabet;
        _searchBar.showsScopeBar = false;
        [self.view addSubview:_searchBar];
    }
    {
        _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        _searchController.delegate = self;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filteredArray count];
    } else {
        return [_array count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSNumber* data;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        data = [_filteredArray objectAtIndex:indexPath.row];
    } else {
        data = [_array objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", [data intValue]];
	return cell;
}

#pragma mark - Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[_filteredArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    NSArray *tempArray = [_array filteredArrayUsingPredicate:predicate];
    _filteredArray = [NSMutableArray arrayWithArray:tempArray];
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

@end
