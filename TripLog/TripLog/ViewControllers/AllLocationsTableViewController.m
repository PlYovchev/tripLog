//
//  AllLocationsTableViewController.m
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/19/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AllLocationsTableViewController.h"

@interface AllLocationsTableViewController () <NSFetchedResultsControllerDelegate>{
    TripLogController *tripManager;
    TripLogCoreDataController *tripCDManager;
}

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) NSArray *filteredList;

typedef NS_ENUM(NSInteger,TripLogSearchScope)
{
    searchScopeTrip = 0,
    searchScopeCreator = 1,
    searchScopeCountry = 2,
    searchScopeCity = 3
};

@end

@implementation AllLocationsTableViewController
static NSString *CellIdentifier = @"locationCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomUIAppearanceStyles];
    
    tripCDManager = [TripLogCoreDataController sharedInstance];
    tripManager = [TripLogController sharedInstance];
    
    tripCDManager.fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![tripCDManager.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Trip Name",@"ScopeButtonTripName"),NSLocalizedString(@"Creator",@"ScopeButtonCreator"),NSLocalizedString(@"Country",@"ScopeButtonCountry"),NSLocalizedString(@"City",@"ScopeButtonCity")];
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    tripCDManager.fetchedResultsController.delegate = nil;
}
-(void)viewDidAppear:(BOOL)animated{
    tripCDManager.fetchedResultsController.delegate = self;
}

#pragma mark UI appearance methods
-(void)setCustomUIAppearanceStyles{
    
    // Navigation bar appearance styles
    self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0 green:255 blue:198 alpha:1] forKey:NSForegroundColorAttributeName];
    
    // View appearance styles
    self.view.backgroundColor = [UIColor blackColor];
    
    // Tab bar appearance styles
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchController.active){
        return [self.filteredList count];
    }else{
        id sectionInfo = [[tripCDManager.fetchedResultsController sections]objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(self.searchController.active){
        Trip *searchedTrip = [self.filteredList objectAtIndex:indexPath.row];
        if (cell == nil) {
            cell = [[LocationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if([cell isMemberOfClass:[LocationsTableViewCell class]]){
            [cell setCellforTrip:searchedTrip];
        }
    }else{
        Trip *currentTrip = [tripCDManager.fetchedResultsController objectAtIndexPath:indexPath];
        if([cell isMemberOfClass:[LocationsTableViewCell class]]){
            [cell setCellforTrip:currentTrip];
        }
    }
    
    if (cell == nil) {
        cell = [[LocationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tripManager.selectedTrip = [tripCDManager.fetchedResultsController objectAtIndexPath:indexPath];
    UIViewController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
    [self.navigationController pushViewController:detailsController animated:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath
                                                                                                      *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if(!controller || !controller.delegate){
        [self.tableView beginUpdates];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if(!controller || !controller.delegate){
        [self.tableView endUpdates];
    }
}

#pragma mark Search
- (void)searchForText:(NSString *)searchText scope:(TripLogSearchScope)scopeOption
{
    if (tripCDManager.mainManagedObjectContext)
    {
        NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
        NSString *searchAttribute = @"name";
        
        if(scopeOption == searchScopeTrip){
            
            searchAttribute = @"name";
        }else if(scopeOption == searchScopeCreator){
            searchAttribute = @"creator.username";
        }else if(scopeOption == searchScopeCountry){
            searchAttribute = @"country";
        }else if(scopeOption == searchScopeCity){
            searchAttribute = @"city";
        }
        
        // Initialize fetch request for trip
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Trip"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
        request.predicate=predicate;
        request.sortDescriptors = tripCDManager.fetchedResultsController.fetchRequest.sortDescriptors;
        
        NSError *error = nil;
        
        // Perform fetch
        self.filteredList = [tripCDManager.mainManagedObjectContext executeFetchRequest:request error:&error];
        if (error)
        {
            NSLog(@"searchFetchRequest failed: %@",[error localizedDescription]);
        }
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

@end
