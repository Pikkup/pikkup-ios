//
//  PULobbyViewController.m
//  picktup
//
//  Created by Planet 1107 on 07/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PULobbyViewController.h"
#import "PUUserCell.h"
#import "PUCommentCell.h"
#import "HPGrowingTextView.h"
#import <SVPullToRefresh.h>
#import "PUProfileViewController.h"

@import EventKit;

@interface PULobbyViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, HPGrowingTextViewDelegate, PUUserCellDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlUsersComments;
@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelMaxPlayers;
@property (weak, nonatomic) IBOutlet UITextView *textViewDescription;
@property (weak, nonatomic) IBOutlet UIView *viewUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableViewUsers;
@property (weak, nonatomic) IBOutlet UIView *viewComments;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;
@property (weak, nonatomic) IBOutlet UIView *viewContainerComment;
@property (strong, nonatomic) HPGrowingTextView *textViewComment;
@property (weak, nonatomic) IBOutlet MKMapView *mapViewParkLocation;

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *comments;

@end

@implementation PULobbyViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _users = [[NSMutableArray alloc] init];
        _comments = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Game lobby";
    
    self.textViewComment = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    self.textViewComment.isScrollable = NO;
    self.textViewComment.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textViewComment.minNumberOfLines = 1;
	self.textViewComment.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
	self.textViewComment.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textViewComment.font = [UIFont systemFontOfSize:15.0f];
	self.textViewComment.delegate = self;
    self.textViewComment.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textViewComment.backgroundColor = [UIColor whiteColor];
    self.textViewComment.placeholder = @"Type your message...";
    //self.textViewMessage.textColor = kSPColorGray149;
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.viewContainerComment.frame.size.width, self.viewContainerComment.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textViewComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self.viewContainerComment addSubview:imageView];
    [self.viewContainerComment addSubview:self.textViewComment];
    [self.viewContainerComment addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(self.viewContainerComment.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    
    //[doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.viewContainerComment addSubview:doneBtn];
    self.viewContainerComment.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self reloadInfo];
    
    [self.tableViewComments addPullToRefreshWithActionHandler:^{
        [self reloadComments:YES];
    }];
    [self.tableViewUsers addPullToRefreshWithActionHandler:^{
        [self reloadUsers:YES];
    }];
    [self.tableViewComments addInfiniteScrollingWithActionHandler:^{
        [self reloadComments:NO];
    }];
    [self.tableViewUsers addInfiniteScrollingWithActionHandler:^{
        [self reloadUsers:NO];
    }];
    [self.tableViewUsers triggerPullToRefresh];
    [self.tableViewComments triggerPullToRefresh];
    
    self.tableViewUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableViewComments.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.mapViewParkLocation addAnnotation:self.event];
    self.mapViewParkLocation.centerCoordinate = self.event.coordinate;
    self.mapViewParkLocation.region = MKCoordinateRegionMakeWithDistance (self.event.coordinate, 100, 1000);
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadInfo {
    
    self.labelMaxPlayers.text = [NSString stringWithFormat:@"Max players: %lu", (unsigned long)self.event.eventMaxPlayers];
    self.textViewDescription.text = self.event.eventDescription;
}


- (void)reloadUsers:(BOOL)reloadAll {
    
    int page = reloadAll ? 1 : (int)self.users.count / kDefaultFetchCount + 1;
    [[PUConnect sharedConnect] usersForEvent:self.event page:page count:kDefaultFetchCount onSuccess:^(NSMutableArray *users) {
        if (reloadAll) {
            [self.users removeAllObjects];
            self.tableViewUsers.infiniteScrollingView.enabled = YES;
        }
        if (users.count < kDefaultFetchCount) {
            self.tableViewUsers.infiniteScrollingView.enabled = NO;
        }
        [self.users addObjectsFromArray:users];
        [self.tableViewUsers.infiniteScrollingView stopAnimating];
        [self.tableViewUsers.pullToRefreshView stopAnimating];
        [self.tableViewUsers reloadData];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.tableViewUsers.infiniteScrollingView stopAnimating];
        [self.tableViewUsers.pullToRefreshView stopAnimating];
        if (serverResponseCode == NOT_FOUND) {
            [self.tableViewUsers reloadData];

        }
    }];
}

- (void)reloadComments:(BOOL)reloadAll {
    
    int page = reloadAll ? 1 : (int)self.comments.count / kDefaultFetchCount + 1;
    [[PUConnect sharedConnect] commentsForEvent:self.event page:page count:kDefaultFetchCount onSuccess:^(NSMutableArray *comments) {

        if (reloadAll) {
            [self.comments removeAllObjects];
            self.tableViewComments.infiniteScrollingView.enabled = YES;
        }
        if (comments.count < kDefaultFetchCount) {
            self.tableViewComments.infiniteScrollingView.enabled = NO;
        }
        [self.comments addObjectsFromArray:comments];
        [self.tableViewComments.infiniteScrollingView stopAnimating];
        [self.tableViewComments.pullToRefreshView stopAnimating];
        [self.tableViewComments reloadData];
        [self.hud hide:NO];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.tableViewUsers.infiniteScrollingView stopAnimating];
        [self.tableViewUsers.pullToRefreshView stopAnimating];
        if (serverResponseCode == NOT_FOUND) {
            [self.tableViewComments reloadData];
        }
        [self.hud hide:NO];
    }];
}

#pragma mark - Action methods

- (IBAction)buttonJoinTouchUpInside:(id)sender {
    
    [self.hud show:YES];
    [PUConnect.sharedConnect joinEvent:self.event onCompletion:^(PUServerResponse serverResponseCode) {
        [self.hud hide:YES];
        if (serverResponseCode == OK) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You just joined event" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error has occured." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (IBAction)buttonAddToCalendarTouchUpInside:(id)sender {
    
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = self.event.eventName;
        event.startDate = self.event.eventStartDate;
        event.endDate = self.event.eventEndDate;
        event.calendar = store.defaultCalendarForNewEvents;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
    }];
}

- (IBAction)segmentedControlUsersCommentsValueChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.viewInfo.alpha = 1.0f;
        self.viewUsers.alpha = 0.0f;
        self.viewComments.alpha = 0.0f;
    } else if (sender.selectedSegmentIndex == 1) {
        self.viewInfo.alpha = 0.0f;
        self.viewUsers.alpha = 1.0f;
        self.viewComments.alpha = 0.0f;
    } else {
        self.viewInfo.alpha = 0.0f;
        self.viewUsers.alpha = 0.0f;
        self.viewComments.alpha = 1.0f;
    }
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableViewUsers) {
        static NSString *CellIdentifier = @"PUUserCell";
        PUUserCell *cell = (PUUserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
            cell.delegate = self;
        }
        PUUser *user = self.users[indexPath.row];
        cell.eventType = self.event.eventType;
        cell.user = user;
        return cell;
    } else {
        static NSString *CellIdentifier = @"PUCommentCell";
        PUCommentCell *cell = (PUCommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
        }
        cell.comment = self.comments[indexPath.row];
        
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (tableView == self.tableViewUsers) {
        return self.users.count;
    } else {
        return self.comments.count;
    }
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableViewUsers == tableView) {
        return 44.0f;
    } else {
        PUComment *comment = self.comments[indexPath.row];
        float height = [PUCommentCell heightWithComment:comment];
        return height;
    }
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Success"]) {
        [self.tableViewUsers triggerPullToRefresh];
    }
}


#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"pin-custom"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}


#pragma mark - HPGrowingTextViewDelegate methods

-(void)resignTextView {
    
	[self.textViewComment resignFirstResponder];
    if (self.textViewComment.text.length) {
        [self.hud show:YES];
        [[PUConnect sharedConnect] addComment:self.textViewComment.text toEvent:self.event onCompletion:^(PUServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                self.textViewComment.text = @"";
                [self reloadComments:YES];
            } else {
                [self.hud hide:YES];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured and your message was not sent, please check your network connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [self.textViewComment becomeFirstResponder];
            }
        }];
    }
}

-(void)keyboardWillShow:(NSNotification *)note {
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.viewContainerComment.frame;
    containerFrame.origin.y = self.viewComments.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.viewContainerComment.frame = containerFrame;
    
	// commit animations
	[UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)note {
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.viewContainerComment.frame;
    containerFrame.origin.y = self.viewComments.bounds.size.height - containerFrame.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.viewContainerComment.frame = containerFrame;
    
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.viewContainerComment.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.viewContainerComment.frame = r;
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - PUUserCellDelegate methods

- (void)cell:(PUUserCell *)cell didTouchUpInsideUserButton:(UIButton *)button {
    
    PUProfileViewController *profileViewController = [[PUProfileViewController alloc] initWithNibName:@"PUProfileViewController" bundle:nil];
    profileViewController.user = cell.user;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
