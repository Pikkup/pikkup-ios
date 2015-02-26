//
//  PUUserPickerViewController.m
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUUserPickerViewController.h"

@interface PUUserPickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarUsers;
@property (strong, nonatomic) IBOutlet UITableView *tableViewUsers;
@property (strong, nonatomic) NSMutableArray *users;

@end

@implementation PUUserPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _users = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select user";
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(barButtonDoneTouchUpInside:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    if (self.initialText.length) {
        self.searchBarUsers.text = self.initialText;
    }
    [self.searchBarUsers becomeFirstResponder];
}

- (void)reloadData {
    
    [self.hud show:YES];
    [[PUConnect sharedConnect] usersForSearchText:self.searchBarUsers.text page:1 count:20 onSuccess:^(NSMutableArray *users) {
        [self.hud hide:NO];
        [self.users removeAllObjects];
        [self.users addObjectsFromArray:users];
        [self.tableViewUsers reloadData];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:NO];
        [[[UIAlertView alloc] initWithTitle:@"No users" message:@"No users found with that name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PUUser *user = self.users[indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = user.userFullName;
    cell.detailTextLabel.text = user.username;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.users.count;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    
}


#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if ([self.searchBarUsers isFirstResponder]) {
        [self.searchBarUsers resignFirstResponder];
    }
    [self reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.searchBarUsers.text = @"";
    [self.users removeAllObjects];
    [self.tableViewUsers reloadData];
}


#pragma mark - Actions methods

- (void)barButtonDoneTouchUpInside:(UIBarButtonItem*)barButtonItem {
    
    if ([self.delegate respondsToSelector:@selector(userPickerViewController: selectedUsers:)]) {
        NSArray *indexPaths = [self.tableViewUsers indexPathsForSelectedRows];
        NSMutableArray *usersSelected = [NSMutableArray arrayWithCapacity:indexPaths.count];
        for (NSIndexPath *indexPath in indexPaths) {
            PUUser *user = self.users[indexPath.row];
            [usersSelected addObject:user];
        }
        [self.delegate userPickerViewController:self selectedUsers:usersSelected];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
