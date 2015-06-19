//
//  AllLocationsTableViewController.m
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/19/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AllLocationsTableViewController.h"

@interface AllLocationsTableViewController (){
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
    
    tripCDManager = [TripLogCoreDataController sharedInstance];
    tripManager = [TripLogController sharedInstance];
    
    NSError *error;
    if (![tripCDManager.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
    //Posledno go slojih ru4no, za6toto poradi nqkakva pri4ina ne mi hva6ta6e indexa na scope butonite.
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
#warning //Dont use it, we dont have direct acces to user's username.
            searchAttribute = @"username";
        }else if(scopeOption == searchScopeCountry){
            searchAttribute = @"country";
        }else if(scopeOption == searchScopeCity){
            searchAttribute = @"city";
        }
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
        tripCDManager.fetchedResultsController.fetchRequest.predicate=predicate;
        
        NSError *error = nil;
        
        self.filteredList = [tripCDManager.mainManagedObjectContext executeFetchRequest:tripCDManager.fetchedResultsController.fetchRequest error:&error];
        if (error)
        {
            NSLog(@"searchFetchRequest failed: %@",[error localizedDescription]);
        }
        
    }
}
#pragma mark === UISearchBarDelegate ===
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}
#pragma mark === UISearchResultsUpdating ===
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

@end
