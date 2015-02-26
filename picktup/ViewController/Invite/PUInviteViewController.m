//
//  PUInviteViewController.m
//  picktup
//
//  Created by Planet 1107 on 07/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUInviteViewController.h"
#import "PUGlobalDefines.h"
#import "PUUserInfoTableViewCell.h"
#import <SVPullToRefresh.h>

@interface PUInviteViewController ()

@property (strong, nonatomic) NSArray *people;
@property (weak, nonatomic) IBOutlet UITableView *tableViewInvite;
@property (strong, nonatomic) NSMutableSet *selectedRows;

@end

@implementation PUInviteViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedRows = [NSMutableSet set];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Invite friends";
    self.tableViewInvite.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewInvite registerNib:[UINib nibWithNibName:@"PUUserInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"PUUserInfoTableViewCell"];
    [self.tableViewInvite addInfiniteScrollingWithActionHandler:^{
        [self reloadData];
    }];
    [self.tableViewInvite triggerInfiniteScrolling];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData {
    
    int page = (int)self.people.count / kDefaultFetchCount + 1;
    [PUConnect.sharedConnect followingForUser:PUConnect.sharedConnect.user page:page count:kDefaultFetchCount onSuccess:^(NSMutableArray *users) {
        self.people = users;
        if (users.count < kDefaultFetchCount) {
            self.tableViewInvite.showsInfiniteScrolling = NO;
        }
        [self.tableViewInvite reloadData];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        self.people = nil;
        [self.tableViewInvite reloadData];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PUUserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PUUserInfoTableViewCell"];
    cell.user = self.people[indexPath.row];
    if ([self.selectedRows containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.people.count;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedRows removeObject:indexPath];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedRows addObject:indexPath];
    }
}


#pragma mark - Action methods

- (IBAction)buttonInviteTouchUpInside:(id)sender {
    
    if (!self.selectedRows.count) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select friends" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        if ([self.delegate respondsToSelector:@selector(invitedUsers:)]) {
            [self.delegate invitedUsers:self.people];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
