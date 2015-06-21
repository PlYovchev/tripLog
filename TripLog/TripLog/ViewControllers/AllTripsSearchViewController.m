//
//  AllTripsSearchViewController.m
//  TripLog
//
//  Created by Miroslav Danazhiev on 6/16/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "AllTripsSearchViewController.h"

@interface AllTripsSearchViewController (){
    TripLogCoreDataController *tripCDManager;
}
@property (weak, nonatomic) IBOutlet UITextField *tripNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *creatorTextField;

@end

@implementation AllTripsSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tripCDManager = [TripLogCoreDataController sharedInstance];
    self.tripNameTextField.text = [tripCDManager.searchCriteria objectForKey:@"name"];
    self.countryTextField.text = [tripCDManager.searchCriteria objectForKey:@"country"];
    self.cityTextField.text = [tripCDManager.searchCriteria objectForKey:@"city"];
    self.creatorTextField.text = [tripCDManager.searchCriteria objectForKey:@"creator"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userDidClickSearchButton:(id)sender {
    NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
    
    if ([self inputDidPassValidationCheckForEmptyString: self.tripNameTextField.text]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", self.tripNameTextField.text];
        [subPredicates addObject:predicate];
        [tripCDManager.searchCriteria setObject:self.tripNameTextField forKey:@"name"];
    }
    
    if ([self inputDidPassValidationCheckForEmptyString:self.countryTextField.text]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == %@", self.countryTextField.text];
        [subPredicates addObject:predicate];
        [tripCDManager.searchCriteria setObject:self.countryTextField forKey:@"country"];
    }
    
    if ([self inputDidPassValidationCheckForEmptyString:self.cityTextField.text]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city == %@", self.cityTextField.text];
        [subPredicates addObject:predicate];
        [tripCDManager.searchCriteria setObject:self.cityTextField forKey:@"city"];
    }
    
    if ([self inputDidPassValidationCheckForEmptyString:self.creatorTextField.text]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creator CONTAINS[c] %@", self.creatorTextField.text ];
        [subPredicates addObject:predicate];
        [tripCDManager.searchCriteria setObject:self.creatorTextField forKey:@"creator"];
    }
    
    
    if (subPredicates != nil) {
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        [NSFetchedResultsController deleteCacheWithName:nil];
        tripCDManager.fetchedResultsController.fetchRequest.predicate=finalPredicate;
        self.searchPredicatesApplied();
    }
    else{
        NSLog(@"No predicates selected!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)userDidClickClearButton:(id)sender {
    NSPredicate *emptyPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[[NSMutableArray alloc] init]];
    
    tripCDManager.fetchedResultsController.fetchRequest.predicate=emptyPredicate;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Search filter cleared!");
}

#pragma mark Input management

// Check if the string is empty or only with white spaces
-(BOOL)inputDidPassValidationCheckForEmptyString: (NSString*)inputString{
    NSString *trimmed = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmed isEqualToString:@""]) {
        return NO;
    }
    else{
        return YES;
    }
}


@end
