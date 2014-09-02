//
//  TodayViewController.h
//  TinyDecision
//
//  Created by Calvin Chestnut on 7/18/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *choiceLabel;
@property (weak, nonatomic) IBOutlet UITableView *choiceTable;
@property (strong, nonatomic) NSMutableDictionary *savedLists;

@end
