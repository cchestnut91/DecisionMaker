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
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chestnut.DecisionMaker.sharedLists"];
    
    if ([mySharedDefaults objectForKey:@"savedLists"]){
        self.savedLists = [mySharedDefaults objectForKey:@"savedLists"];
    }
    [mySharedDefaults setObject:self.savedLists forKey:@"savedLists"];
    [self.choiceTable reloadData];
    
    [self.choiceLabel setText:@"Select list to make a choice"];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setPreferredContentSize:CGSizeMake(self.choiceTable.contentSize.width, self.choiceTable.contentSize.height + 48)];
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chestnut.DecisionMaker.sharedLists"];
    
    bool update = NO;
    if ([mySharedDefaults objectForKey:@"savedLists"]){
        NSDictionary *newLists = [mySharedDefaults objectForKey:@"savedLists"];
        if (newLists.count == self.savedLists.count){
            for (NSString *key in newLists){
                if (![self.savedLists objectForKey:key]){
                    update = YES;
                    break;
                } else if (![[self.savedLists objectForKey:key] isEqualToArray:[newLists objectForKey:key]]){
                    update = YES;
                    break;
                }
            }
        } else {
            update = YES;
        }
        if (update){
            self.savedLists = [NSMutableDictionary dictionaryWithDictionary:newLists];
            [mySharedDefaults setObject:self.savedLists forKey:@"savedLists"];
            completionHandler(NCUpdateResultNewData);
        } else {
            completionHandler(NCUpdateResultNoData);
        }
    } else {
        completionHandler(NCUpdateResultFailed);
    }
}

@end
