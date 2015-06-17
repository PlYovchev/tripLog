//
//  AllTripsCollectionViewController.m
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/12/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AllTripsCollectionViewController.h"

@interface AllTripsCollectionViewController (){
    TripLogController *tripManager;
    TripLogCoreDataController *tripCDManager;
}


@end

@implementation AllTripsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    tripCDManager = [TripLogCoreDataController sharedInstance];
    tripManager = [TripLogController sharedInstance];
    NSError *error;
    if (![tripCDManager.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTapped:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

-(IBAction)cancelButtonTapped:(id)sender{
    tripCDManager.fetchedResultsController.fetchRequest.predicate = nil;
    NSError *error;
    if (![tripCDManager.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
    [self.collectionView reloadData];
}

- (IBAction)searchButtonTapped:(id)sender {
    AllTripsSearchViewController* searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"allTripsSearch"];
    searchViewController.searchPredicatesApplied = ^{
        NSError *error;
        if (![tripCDManager.fetchedResultsController performFetch:&error]) {
            NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
        }
        [self.collectionView reloadData];
    };
    
    
    UIPopoverController *popoverController = [[UIPopoverController alloc]initWithContentViewController:searchViewController];
    popoverController.popoverContentSize = CGSizeMake(300, 400);
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id sectionInfo = [[tripCDManager.fetchedResultsController sections]objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AllTripsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    Trip *currentTrip = [tripCDManager.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell setCellforTrip:currentTrip];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    tripManager.selectedTrip = [tripCDManager.fetchedResultsController objectAtIndexPath:indexPath];
    UIViewController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
    [self.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat picDimension = self.view.frame.size.width / 4.0f;
    return CGSizeMake(picDimension, picDimension);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat leftRightInset = self.view.frame.size.width / 14.0f;
    return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset);
}


@end
