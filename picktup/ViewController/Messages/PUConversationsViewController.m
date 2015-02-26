//
//  PUMessagesViewController.m
//  picktup
//
//  Created by Josip Cavar on 26/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUConversationsViewController.h"
#import "PUMessageUserTableViewCell.h"
#import "PUMessagesViewController.h"
#import "PUNewMessageViewController.h"

@interface PUConversationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewConversations;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation PUConversationsViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Conversations";
    self.tableViewConversations.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers.count == 1) {
        UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonAdd addTarget:self action:@selector(buttonAddTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *imageButton = [UIImage imageNamed:@"nav-btn-add"];
        buttonAdd.bounds = CGRectMake(0, 0, imageButton.size.width, imageButton.size.height);
        [buttonAdd setImage:imageButton forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
        self.navigationItem.rightBarButtonItem = barButtonItemAdd;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    
    [self.hud show:YES];
    [[PUConnect sharedConnect] messagesPage:1 count:20 onSuccess:^(NSMutableArray *messages) {
        [self.hud hide:NO];
        [self.messages removeAllObjects];
        [self.messages addObjectsFromArray:messages];
        [self.tableViewConversations reloadData];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:NO];
        if (serverResponseCode == NOT_FOUND) {
            [self.messages removeAllObjects];
            [self.tableViewConversations reloadData];
        }
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PUMessageUserTableViewCell";
    PUMessageUserTableViewCell *cell = (PUMessageUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
    }
    cell.message = self.messages[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.messages.count;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    PUMessagesViewController *messageViewController = [[PUMessagesViewController alloc] initWithNibName:@"PUMessagesViewController" bundle:nil];
    PUMessage *message = self.messages[indexPath.row];
    PUUser *user;
    if (PUConnect.sharedConnect.user.userId == message.userFrom.userId) {
        user = message.userTo;
    } else {
        user = message.userFrom;
    }
    messageViewController.user = user;
    [self.navigationController pushViewController:messageViewController animated:YES];
}


#pragma mark - Actions methods

- (void)buttonAddTouchUpInside:(UIButton*)button {
    
    PUNewMessageViewController *newMessageViewController = [[PUNewMessageViewController alloc] initWithNibName:@"PUNewMessageViewController" bundle:nil];
    [self.navigationController pushViewController:newMessageViewController animated:YES];
}

@end
