//
//  PUGamesViewController.m
//  picktup
//
//  Created by Josip Cavar on 02/09/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUGamesViewController.h"
#import "PUEventCell.h"
#import "PULobbyViewController.h"

@interface PUGamesViewController ()

@property (strong, nonatomic) NSArray *events;
@property (weak, nonatomic) IBOutlet UITableView *tableViewGames;

@end

@implementation PUGamesViewController

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
    self.tableViewGames.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"My Games";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    
    [self.hud show:YES];
    [[PUConnect sharedConnect] eventsForCurrentUserPage:1 count:20000 onSuccess:^(NSMutableArray *events) {
        [self.hud hide:NO];
        self.events = events;
        [self.tableViewGames reloadData];
        
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
    
    if (self.events.count) {
        static NSString *CellIdentifier = @"PUEventCell";
        PUEventCell *cell = (PUEventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil].firstObject;
        }
        PUEvent *event = self.events[indexPath.row];
        cell.event = event;
        return cell;
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
        cell.textLabel.text = @"There are no games";
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.events.count + !self.events.count;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:PUEventCell.class]) {
        PULobbyViewController *lobbyViewController = [[PULobbyViewController alloc] initWithNibName:@"PULobbyViewController" bundle:nil];
        lobbyViewController.event = self.events[indexPath.row];;
        [self.navigationController pushViewController:lobbyViewController animated:YES];
    }

}

@end
