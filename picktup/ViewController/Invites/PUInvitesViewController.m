//
//  PUInvitesViewController.m
//  picktup
//
//  Created by Josip Cavar on 02/09/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUInvitesViewController.h"
#import "PUInviteTableViewCell.h"

@interface PUInvitesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableViewInvites;
@property (strong, nonatomic) NSArray *invites;

@end

@implementation PUInvitesViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableViewInvites.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"Invites";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    
    [self.hud show:YES];
    [[PUConnect sharedConnect] invitesForCurrentUserPage:1 count:20000 onSuccess:^(NSMutableArray *invites) {
        [self.hud hide:NO];
        self.invites = invites;
        [self.tableViewInvites reloadData];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.invites.count) {
        
        static NSString *CellIdentifier = @"PUInviteTableViewCell";
        PUInviteTableViewCell *cell = (PUInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil].firstObject;
        }
        cell.invite = self.invites[indexPath.row];
        return cell;
        
        return nil;
    } else {
        static NSString *CellIdentifier = @"PUEmptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            //cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedRegular" size:14];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        cell.textLabel.text = @"There are no invites";
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.invites.count + !self.invites.count;
}

@end
