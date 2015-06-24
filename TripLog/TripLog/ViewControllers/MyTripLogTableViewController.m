//
//  MyTripLogViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "MyTripLogTableViewController.h"
#import "TripLogWebServiceController.h"
#import "TripLogCoreDataController.h"
#import "LocationsTableViewCell.h"
#import "LocationDetailsViewController.h"
#import "Trip.h"

@interface MyTripLogTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchResultController;

@end

@implementation MyTripLogTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomUIAppearanceStyles];
    
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController setVisitedTripsFetchedResultsController:nil];
    self.fetchResultController = [dataController visitedTripsFetchedResultsController];
    self.fetchResultController.delegate = self;
    
    NSError *error;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    self.fetchResultController.delegate = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    self.fetchResultController.delegate = self;
    
    NSError *error;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
}

#pragma mark UI appearance methods
-(void)setCustomUIAppearanceStyles{
    
    // Navigation bar appearance styles
    self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0 green:255 blue:198 alpha:1] forKey:NSForegroundColorAttributeName];
    
    // View appearance styles
//    self.view.backgroundColor = [UIColor blackColor];
    
    // Tab bar appearance styles
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:0 green:255 blue:198 alpha:1];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id sectionInfo = [[self.fetchResultController sections]objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocationsTableViewCell* tripCell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
    [self configureCell:tripCell atIndexPath:indexPath];
    return tripCell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Trip* tripItem = [self.fetchResultController objectAtIndexPath:indexPath];
    LocationsTableViewCell* tripCell = (LocationsTableViewCell*)cell;
    [tripCell setCellforTrip:tripItem];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TripLogController* tripController = [TripLogController sharedInstance];
    tripController.selectedTrip = [self.fetchResultController objectAtIndexPath:indexPath];
    LocationDetailsViewController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
    detailsController.locationVisited = YES;
    [self.navigationController pushViewController:detailsController animated:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath
                                                                                                      *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
