//
//  ToDoTableViewCell.m
//  TripLog
//
//  Created by plt3ch on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "ToDoTableViewCell.h"
#import "TripLogCoreDataController.h"
#import "ToDoItem+DictionaryInitializator.h"
#import "TripLogController.h"

@interface ToDoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *toDoLabel;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;

@end

@implementation ToDoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)stateButtonTapped:(id)sender {
    NSDictionary* toDoItemProp = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithString:self.toDoItem.task], TO_DO_TASK_KEY,
                                  [NSNumber numberWithBool:![self.toDoItem.isDone boolValue]], TO_DO_IS_DONE_KEY,
                                  [NSString stringWithString:self.toDoItem.user.userId], TO_DO_USER_ID_KEY,
                                  [NSString stringWithString:self.toDoItem.trip.tripId], TO_DO_TRIP_ID_KEY,
                                  [NSString stringWithString:self.toDoItem.toDoItemId], TO_DO_ITEM_ID_KEY,
                                  [NSNumber numberWithBool:[self.toDoItem.isSynchronized boolValue]], TO_DO_IS_SYNCHRONIZED_KEY,
                                  nil];
    
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController.mainManagedObjectContext deleteObject:self.toDoItem];
    [dataController addToDoItem:toDoItemProp];
    [dataController.mainManagedObjectContext save:nil];
}

-(void)setToDoItem:(ToDoItem *)toDoItem{
    _toDoItem = toDoItem;
    
    self.toDoLabel.text = toDoItem.task;
    bool isDone = [toDoItem.isDone boolValue];
    if (isDone){
        [self.stateButton setBackgroundImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateNormal];
    }
    else{
        [self.stateButton setBackgroundImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    }
}

@end
