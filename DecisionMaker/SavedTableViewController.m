//
//  SavedTableViewController.m
//  DecisionMaker
//
//  Created by Calvin Chestnut on 7/16/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "SavedTableViewController.h"

@interface SavedTableViewController ()

@end

@implementation SavedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainView = (ViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
    NSLog(@"%@", [self.presentingViewController class]);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.mainView.savedLists.allKeys.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.mainView.savedLists removeObjectForKey:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.mainView saveLists];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    
    NSString *key = [[[self.mainView savedLists] allKeys] objectAtIndex:indexPath.row];
    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%lu Items",(unsigned long)[(NSMutableArray *)[[self.mainView savedLists] objectForKey:key] count]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.mainView.savedLists objectForKey:[[tableView cellForRowAtIndexPath:indexPath] textLabel].text]){
        
        if ([[self.mainView.savedLists allValues] containsObject:self.mainView.options] || self.mainView.options.count == 0){
            self.mainView.options = [self.mainView.savedLists objectForKey:[[tableView cellForRowAtIndexPath:indexPath] textLabel].text];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.selected = indexPath;
            UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Clear List" message:@"This will delete the unsaved list currently being used. Are you sure you want to do this? To save go back to the previous screen and click 'Save List'." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [confirm show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView title] isEqualToString:@"Clear List"]){
        if (buttonIndex != 0){
            self.mainView.options = [self.mainView.savedLists objectForKey:[[self.tableView cellForRowAtIndexPath:self.selected] textLabel].text];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
