//
//  SavedTableViewController.h
//  DecisionMaker
//
//  Created by Calvin Chestnut on 7/16/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface SavedTableViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) ViewController *mainView;
@property (strong, nonatomic) NSIndexPath *selected;

@end
