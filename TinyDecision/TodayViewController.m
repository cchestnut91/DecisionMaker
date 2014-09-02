//
//  TodayViewController.m
//  TinyDecision
//
//  Created by Calvin Chestnut on 7/18/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    BOOL showAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.savedLists = [[NSMutableDictionary alloc] init];
    [self.choiceTable setDataSource:self];
    [self.choiceTable setDelegate:self];
    
    showAll = NO;
    
    NSLog(@"ViewIsLoading");
    [self.choiceLabel setText:@"viewDidLoad"];
    
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chestnut.DecisionMaker.sharedLists"];
    
    if ([mySharedDefaults objectForKey:@"savedLists"]){
        self.savedLists = [mySharedDefaults objectForKey:@"savedLists"];
    }
    [mySharedDefaults setObject:self.savedLists forKey:@"savedLists"];
    [self.choiceTable reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.choiceLabel setText:@"Select list to make a choice"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setPreferredContentSize:CGSizeMake(self.choiceTable.contentSize.width, self.choiceTable.contentSize.height + 48)];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chestnut.DecisionMaker.sharedLists"];
    
    if ([mySharedDefaults objectForKey:@"savedLists"]){
        self.savedLists = [mySharedDefaults objectForKey:@"savedLists"];
    }
    [mySharedDefaults setObject:self.savedLists forKey:@"savedLists"];
    [self.choiceTable reloadData];
    //[self setPreferredContentSize:CGSizeMake(self.choiceTable.frame.size.width, (self.choiceTable.rowHeight * [self.choiceTable numberOfRowsInSection:0]) + self.choiceLabel.frame.size.height)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    [self.choiceLabel setText:@"Updating Table"];
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numLists = self.savedLists.count;
    if (numLists > 5 && !showAll){
        return 6;
    }
    return self.savedLists.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.savedLists.count){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newListCell"];
        return cell;
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showAll"];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
        NSString *key = [[[self savedLists] allKeys] objectAtIndex:indexPath.row];
        [[cell textLabel] setText:key];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%lu Items",(unsigned long)[(NSMutableArray *)[[self savedLists] objectForKey:key] count]]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1 && indexPath.row != self.savedLists.count){
        showAll = YES;
        [tableView reloadData];
        [self setPreferredContentSize:CGSizeMake(self.choiceTable.contentSize.width, self.choiceTable.contentSize.height + 48)];
    } else if (indexPath.row != self.savedLists.count){
        NSArray *options = [self.savedLists objectForKey:[[tableView cellForRowAtIndexPath:indexPath] textLabel].text];
        NSUInteger randomIndex = arc4random() % [options count];
        NSLog(@"%lu",(unsigned long)randomIndex);
        [self.choiceLabel setText:[options objectAtIndex:randomIndex]];
    } else {
        NSURL *appURL = [[NSURL alloc] initWithString:@"MakeChoices://"];
        [[self extensionContext] openURL:appURL completionHandler:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
