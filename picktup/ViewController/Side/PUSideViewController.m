//
//  PUSideViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSideViewController.h"
#import "PUGameViewController.h"
#import "PUProfileViewController.h"
#import "PUConversationsViewController.h"
#import "PUSideTableViewCell.h"
#import "PUAppDelegate.h"
#import "PUSideHeaderView.h"
#import "PUInvitesViewController.h"
#import "PUGamesViewController.h"

@interface PUSideViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableViewSide;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSArray *optionsImages;

@end

@implementation PUSideViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _sections = @[@"Game type", @"Options"];
        _options = @[@[@"All games", @"Soccer", @"Basketball", @"Football", @"Baseball", @"Softball", @"Golf", @"Tennis", @"Ultimate frisbee", @"Cricket", @"Volleyball", @"Racquetball", @"Handball", @"Rugby", @"Hockey"], @[@"My profile", @"Messages", @"Invites", @"My games"]];
        _optionsImages = @[@[@"nav-btn-menu.png", @"icon-soccer.png", @"icon-basketball.png", @"icon-football.png", @"icon-softball.png", @"icon-softball.png", @"icon-golf.png", @"icon-tennis.png", @"icon-frisbee.png", @"icon-cricket.png", @"icon-volleyball.png", @"icon-racquetball.png", @"icon-handball.png", @"icon-rugby.png", @"icon-hockey.png"], @[@"icon-profile.png", @"icon-messages.png", @"icon-invite.png", @"icon-my-games.png"]];
        _navigationControllers = [NSMutableArray array];
        
        for (PUEventType eventType = PUEventTypeAll; eventType <= [_options[0] count]; eventType++) {
            PUGameViewController *gameViewController = [[PUGameViewController alloc] initWithNibName:@"PUGameViewController" bundle:nil];
            gameViewController.eventType = eventType;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:gameViewController];
            navigationController = [self customizeNavigationViewController:navigationController];
            [_navigationControllers addObject:navigationController];
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PUProfileViewController alloc] initWithNibName:@"PUProfileViewController" bundle:nil]];
        navigationController = [self customizeNavigationViewController:navigationController];
        [_navigationControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[PUConversationsViewController alloc] initWithNibName:@"PUConversationsViewController" bundle:nil]];
        navigationController = [self customizeNavigationViewController:navigationController];
        [_navigationControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[PUInvitesViewController alloc] initWithNibName:@"PUInvitesViewController" bundle:nil]];
        navigationController = [self customizeNavigationViewController:navigationController];
        [_navigationControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[PUGamesViewController alloc] initWithNibName:@"PUGamesViewController" bundle:nil]];
        navigationController = [self customizeNavigationViewController:navigationController];
        [_navigationControllers addObject:navigationController];
        
    }
    return self;
}

- (UINavigationController *)customizeNavigationViewController:(UINavigationController *)navigationController {
    
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    return navigationController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"PUSideTableViewCell" bundle:nil];
    [self.tableViewSide registerNib:nib forCellReuseIdentifier:@"PUSideTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.tableViewSide reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PUSideTableViewCell *cell = (PUSideTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PUSideTableViewCell" forIndexPath:indexPath];
    cell.labelTitle.text = self.options[indexPath.section][indexPath.row];
    
    PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSUInteger index = [self.navigationControllers indexOfObject:appDelegate.viewDeckController.centerController];
    if (indexPath.section == 0 && index != NSNotFound && index == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-checkmark"]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    cell.imageView.image = [UIImage imageNamed:self.optionsImages[indexPath.section][indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.options[section] count];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.viewDeckController.centerController = self.navigationControllers[indexPath.section * [_options[0] count] + indexPath.row];
    if (appDelegate.viewDeckController.centerController.class == [PUGameViewController class]) {
        [(PUGameViewController *)appDelegate.viewDeckController.centerController reloadOnUserLocation];
    }
    [appDelegate.viewDeckController toggleLeftViewAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return self.sections[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PUSideHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"PUSideHeaderView" owner:self options:nil].firstObject;
    headerView.labelTitle.text = [self tableView:self.tableViewSide titleForHeaderInSection:section];
    return headerView;
}

@end
