//
//  PUNotificationsSettingsViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/11/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUNotificationsSettingsViewController.h"
#import "PUNotificationCell.h"

@interface PUNotificationsSettingsViewController () <UITableViewDataSource, PUNotificationCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewNotifications;

@end

@implementation PUNotificationsSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Notifications";
    
    UINib *nib = [UINib nibWithNibName:@"PUNotificationCell" bundle:nil];
    [self.tableViewNotifications registerNib:nib forCellReuseIdentifier:@"PUNotificationCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PUNotificationCell *cell = (PUNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"PUNotificationCell" forIndexPath:indexPath];
    cell.skillType = indexPath.row + 2;
    NSArray *skills = [self.user.userSkills valueForKeyPath:@"@unionOfObjects.skillGameTypeId"];
    NSUInteger index = [skills indexOfObject:@(indexPath.row + 2)];
    cell.skill =  index != NSNotFound ? self.user.userSkills[index] : nil;
    cell.delegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 8;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
}


#pragma mark - PUNotificationCellDelegate methods

- (void)cell:(UITableViewCell *)cell didChangeSkillNotifyToUser:(PUUser *)user {
    
    self.user = user;
    [self.tableViewNotifications reloadData];
}

@end
