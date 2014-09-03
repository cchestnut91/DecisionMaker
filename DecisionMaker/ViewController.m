//
//  ViewController.m
//  DecisionMaker
//
//  Created by Calvin Chestnut on 7/16/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    BOOL isBannerVisible;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.options = [[NSMutableArray alloc] init];
    self.savedLists = [[NSMutableDictionary alloc] init];
    [self.choicesTable setDataSource:self];
    [self.choicesTable setDelegate:self];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chestnut.DecisionMaker.sharedLists"];
    
    if ([mySharedDefaults objectForKey:@"savedLists"]){
        self.savedLists = [NSMutableDictionary dictionaryWithDictionary:[mySharedDefaults objectForKey:@"savedLists"]];
        for (id key in self.savedLists.allKeys){
            NSLog(@"%d",self.savedLists.count);
            NSMutableArray *new = [NSMutableArray arrayWithArray:[self.savedLists objectForKey:key]];
            [self.savedLists setObject:new forKey:key];
            NSLog(@"%d",self.savedLists.count);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.choicesTable reloadData];
    isBannerVisible = NO;
    
    self.bottomSpace.constant = 0;
    [self.view layoutIfNeeded];
    self.adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 50)];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.view addSubview:self.adView];
    [self.adView setDelegate:self];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!isBannerVisible)
    {
        self.bottomSpace.constant = 50;
        
        if (self.adView.superview == nil)
        {
            [self.view addSubview:self.adView];
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
            self.adView.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
        }completion:^(BOOL finished){
            isBannerVisible = YES;
        }];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (isBannerVisible)
    {
        self.bottomSpace.constant = 0;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
            self.adView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 50);
        }completion:^(BOOL finished){
            isBannerVisible = NO;
        }];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.options.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
    [[cell textLabel] setText:[self.options objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.options removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (self.options.count == 0){
            for (id key in self.savedLists.allKeys){
                if ([[self.savedLists objectForKey:key] isEqual:self.options]){
                    [self.savedLists removeObjectForKey:key];
                }
            }
        }
        [self saveLists];
    }
}

- (IBAction)clickChoose:(id)sender {
    if (self.options.count == 0){
        UIAlertView *noOptions = [[UIAlertView alloc] initWithTitle:@"No Options to choose from" message:@"You need at least one option in the choices table" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        [noOptions show];
    } else {
        NSUInteger randomIndex = arc4random() % [self.options count];
        NSLog(@"%lu",(unsigned long)randomIndex);
        [self.topLabel setText:[self.options objectAtIndex:randomIndex]];
    }
}

- (IBAction)clickSave:(id)sender {
    if (self.options.count == 0){
        UIAlertView *noOptions = [[UIAlertView alloc] initWithTitle:@"Empty List" message:@"There's no real reason to save an empty list. Add some items first" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        [noOptions show];
    } else {
        UIAlertView *save = [[UIAlertView alloc] initWithTitle:@"Save List" message:@"What would you like to name this list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        [save setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [save show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Save List"]){
        if (buttonIndex != 0){
            NSString *title = [[alertView textFieldAtIndex:0] text];
            if ([title isEqualToString:@""]){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MMM d, h:m"];
                title = [formatter stringFromDate:[[NSDate alloc] init]];
            }
            [self.savedLists setObject:self.options forKey:title];
            [self saveLists];
        }
    } else if ([[alertView title] isEqualToString:@"Clear List"]){
        if (buttonIndex != 0){
            self.options = [[NSMutableArray alloc] init];
            [self.choicesTable reloadData];
            [self.topLabel setText:@"Add Option"];
        }
    }
}

- (IBAction)clickClear:(id)sender {
    if ([[self.savedLists allValues] containsObject:self.options] || self.options.count == 0){
        self.options = [[NSMutableArray alloc] init];
        [self.choicesTable reloadData];
        [self.topLabel setText:@"Add Option"];
    } else {
        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Clear List" message:@"Are you sure you want to clear this list without saving it?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [confirm show];
    }
}
- (IBAction)finishAdding:(id)sender {
    if (![[(UITextField *)sender text] isEqualToString:@""]){
        [self.options addObject:[(UITextField *)sender text]];
        [self.choicesTable reloadData];
        [self.addField setText:@""];
        [self.addField resignFirstResponder];
    }
}

-(void)saveLists{
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chestnut.DecisionMaker.sharedLists"];
    
    
    // Use the shared user defaults object to update the user's account.
    [mySharedDefaults setObject:self.savedLists forKey:@"savedLists"];
    
}

@end
