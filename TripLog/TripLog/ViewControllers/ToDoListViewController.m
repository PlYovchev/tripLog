//
//  ToDoListViewController.m
//  TripLog
//
//  Created by plt3ch on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ToDoListViewController.h"
#import "TripLogCoreDataController.h"
#import "TripLogController.h"
#import "ToDoTableViewCell.h"
#import "NSString+Validation.h"
#import "ToDoItem+DictionaryInitializator.h"

#define TO_DO_ITEM_CELL @"ToDoTableViewCell"

@interface ToDoListViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *toDoTextView;
@property (weak, nonatomic) IBOutlet UITableView *toDoTableView;

@property (nonatomic, strong) NSFetchedResultsController* fetchResultController;

@end

@implementation ToDoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"To do list!";
    
    self.toDoTableView.delegate = self;
    self.toDoTableView.dataSource = self;
    self.toDoTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.toDoTableView.bounds.size.width, 0.01f)];
    //self.toDoTableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController setToDoListFetchedResultsController:nil];
    self.fetchResultController = [dataController toDoListFetchedResultsController];
    self.fetchResultController.delegate = self;
    
    NSError *error;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(range.length + range.location > self.toDoTextView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [self.toDoTextView.text length] + [text length] - range.length;
    return newLength <= 80;
}

- (IBAction)addButtonTapped:(id)sender {
    if([self.toDoTextView.text isEmpty]){
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Incorrect or missing values!"
                                                                                 message:@"Some of the fields have incorrect data!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    TripLogController* tripController = [TripLogController sharedInstance];
    
    NSString* task = self.toDoTextView.text;
    NSNumber* isDone = [NSNumber numberWithBool:NO];
    User* user = tripController.loggedUser;
    Trip* trip = tripController.selectedTrip;
    NSString* toDoItemId = [[NSUUID UUID] UUIDString];
    
    NSDictionary* toDoItemProp = [NSDictionary dictionaryWithObjectsAndKeys:
                                  task, TO_DO_TASK_KEY,
                                  isDone, TO_DO_IS_DONE_KEY,
                                  user.userId, TO_DO_USER_ID_KEY,
                                  trip.tripId, TO_DO_TRIP_ID_KEY,
                                  toDoItemId, TO_DO_ITEM_ID_KEY,
                                  @(NO), TO_DO_IS_SYNCHRONIZED_KEY,
                                  nil];
    
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController addToDoItem:toDoItemProp];
    self.toDoTextView.text = @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id sectionInfo = [[self.fetchResultController sections]objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ToDoTableViewCell* toDoItemCell = [tableView dequeueReusableCellWithIdentifier:TO_DO_ITEM_CELL forIndexPath:indexPath];
    [self configureCell:toDoItemCell atIndexPath:indexPath];
    return toDoItemCell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ToDoItem* toDoItem = [self.fetchResultController objectAtIndexPath:indexPath];
    ToDoTableViewCell* toDoItemCell = (ToDoTableViewCell*)cell;
    toDoItemCell.toDoItem = toDoItem;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath
                                                                                                      *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.toDoTableView;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
