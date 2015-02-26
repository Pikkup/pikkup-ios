//
//  PUFindViewController.m
//  picktup
//
//  Created by Josip Cavar on 22/07/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUFindViewController.h"
#import "PUUserInfoTableViewCell.h"
#import "PUProfileViewController.h"
#import <SVPullToRefresh.h>

@interface PUFindViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPeople;
@property (strong, nonatomic) NSMutableArray *people;

@end

@implementation PUFindViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _people = [NSMutableArray array];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Find friends";
    self.tableViewPeople.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewPeople registerNib:[UINib nibWithNibName:@"PUUserInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"PUUserInfoTableViewCell"];
    [self.tableViewPeople addInfiniteScrollingWithActionHandler:^{
        [self reloadData:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)reloadData:(BOOL)reloadAll {
    
    if (self.searchBar.text.length > 0) {
        int page = reloadAll ? 1 : (int)self.people.count / kDefaultFetchCount + 1;
        [self.tableViewPeople.infiniteScrollingView startAnimating];
        [PUConnect.sharedConnect usersForSearchText:self.searchBar.text page:page count:kDefaultFetchCount onSuccess:^(NSMutableArray *users) {
            if (reloadAll) {
                self.tableViewPeople.infiniteScrollingView.enabled = YES;
                [self.people removeAllObjects];
            }
            if (users.count < kDefaultFetchCount) {
                self.tableViewPeople.infiniteScrollingView.enabled = NO;
            }
            [self.people addObjectsFromArray:users];
            [self.tableViewPeople.infiniteScrollingView stopAnimating];
            [self.tableViewPeople reloadData];
        } onFaliure:^(PUServerResponse serverResponseCode) {
            [self.people removeAllObjects];
            [self.tableViewPeople.infiniteScrollingView stopAnimating];
            [self.tableViewPeople reloadData];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter search text." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
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


#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self reloadData:YES];
    [self.searchBar resignFirstResponder];
}

@end
