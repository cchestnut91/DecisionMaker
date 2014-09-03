//
//  ViewController.h
//  DecisionMaker
//
//  Created by Calvin Chestnut on 7/16/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) NSMutableArray *options;
@property (strong, nonatomic) NSMutableDictionary *savedLists;
@property (weak, nonatomic) IBOutlet UITableView *choicesTable;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *addField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet ADBannerView *adView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;

- (IBAction)clickChoose:(id)sender;
- (IBAction)clickSave:(id)sender;
- (IBAction)clickClear:(id)sender;
- (IBAction)finishAdding:(id)sender;
-(void)saveLists;

@end

