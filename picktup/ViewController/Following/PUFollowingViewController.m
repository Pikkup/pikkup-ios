//
//  PUFollowingViewController.m
//  picktup
//
//  Created by Planet 1107 on 09/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUFollowingViewController.h"
#import "PUUserInfoTableViewCell.h"
#import "PUProfileViewController.h"
#import <SVPullToRefresh.h>

@interface PUFollowingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableViewUsers;
@property (strong, nonatomic) NSArray *people;

@end

@implementation PUFollowingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Following";
    self.tableViewUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewUsers registerNib:[UINib nibWithNibName:@"PUUserInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"PUUserInfoTableViewCell"];
    [self.tableViewUsers addInfiniteScrollingWithActionHandler:^{
        [self reloadData];
    }];
    [self.tableViewUsers triggerInfiniteScrolling];
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
            self.tableViewUsers.showsInfiniteScrolling = NO;
        }
        [self.tableViewUsers reloadData];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        self.people = nil;
        [self.tableViewUsers reloadData];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PUUserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PUUserInfoTableViewCell"];
    cell.user = self.people[indexPath.row];
    cell.shouldShowFollowUnfollowButton = YES;
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
    PUProfileViewController *profileViewController = [[PUProfileViewController alloc] initWithNibName:@"PUProfileViewController" bundle:nil];
    profileViewController.user = self.people[indexPath.row];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
