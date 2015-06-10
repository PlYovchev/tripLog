//
//  LocationsViewController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "LocationsViewController.h"

@interface LocationsViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>{
    TripLogController *tripManager;
    TripLogWebServiceController *tripWebService;
}

@property (weak, nonatomic) IBOutlet UITableView *locationsTableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong,nonatomic) NSString *url;

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tripManager = [TripLogController sharedInstance];
    self.locationsTableView.delegate = self;
    self.locationsTableView.dataSource = self;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Fetching data failed. Error %@, %@", error, [error userInfo]);
    }
    
    self.locationsTableView.editing = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id sectionInfo =
    [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocationsTableViewCell *cell = [self.locationsTableView dequeueReusableCellWithIdentifier:@"locationsCell"];
    Trip *currentTrip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *tripID=currentTrip.tripId;

    [[TripLogWebServiceController sharedInstance]sendGetRequestForImagesWithTripId:tripID andCompletitionHandler:^(NSDictionary *result) {
        if(result!=nil){
            //NSLog(@"Cell fetch images result:%@",result);
            self.url=[result objectForKey:@"url"];
            NSLog(@"Image url:%@",self.url);
        }else{
            //NSLog(@"Cell fetch unsuccessfull!");
        }
    } ];
    
  
    [cell setLocationsCellForTrip:currentTrip withURL:self.url];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.locationsTableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [TripLogCoreDataController removeObjectAtIndex: indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UIViewController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
    tripManager.selectedTrip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark FetchedResultsControllerDelegate

-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [[TripLogCoreDataController sharedInstance] mainManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip"
                                              inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"Content changed!");
    [self.locationsTableView reloadData];
}

@end
