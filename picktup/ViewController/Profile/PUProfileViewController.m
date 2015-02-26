//
//  PUProfileViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUProfileViewController.h"
#import "PUFollowersViewController.h"
#import "PUFollowingViewController.h"
#import "PUAppDelegate.h"
#import "PUSkillCell.h"
#import "PUFindViewController.h"
#import "PUNewMessageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PUConnect.h"
#import "PNTToolbar.h"
#import "JCACameraGalleryBehaviour.h"
#import "PUNotificationsSettingsViewController.h"

@import MessageUI;

@interface PUProfileViewController () <PUSkillCellDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewMain;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFullName;
@property (weak, nonatomic) IBOutlet UIButton *buttonImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UITextField *textFieldHomePark;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFavoriteSport;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFavoriteTeams;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFavoritePlayer;
@property (strong, nonatomic) IBOutlet UITableView *tableViewSkills;

@property (strong, nonatomic) UIBarButtonItem *barButtonItemSettings;
@property (strong, nonatomic) UIBarButtonItem *barButtonItemDone;

@property (weak, nonatomic) IBOutlet JCACameraGalleryBehaviour *behaviourPhotoPicker;

@end

@implementation PUProfileViewController

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
    self.title = @"Profile";
    UINib *nib = [UINib nibWithNibName:@"PUSkillCell" bundle:nil];
    [self.tableViewSkills registerNib:nib forCellReuseIdentifier:@"PUSkillCell"];
    
    self.scrollViewMain.contentSize = CGSizeMake(CGRectGetWidth(self.scrollViewMain.frame), 300.0f);
    
    PNTToolbar *toolbar = [PNTToolbar defaultToolbar];
    toolbar.inputFields = @[self.textFieldFullName, self.textFieldUsername, self.textFieldHomePark, self.textFieldFavoriteSport, self.textFieldFavoriteTeams, self.textFieldFavoritePlayer];
    toolbar.mainScrollView = self.scrollViewMain;
    
    if (!self.user || self.user.userId == [PUConnect sharedConnect].user.userId) {
        self.user = [PUConnect sharedConnect].user;
    }
    if (self.user) {
        self.textFieldFullName.text = self.user.userFullName;
        self.textFieldUsername.text = self.user.username;
        self.textFieldHomePark.text = self.user.userHomePark;
        self.textFieldFavoriteSport.text = self.user.userFavoriteSport;
        self.textFieldFavoriteTeams.text = self.user.userFavoriteTeams;
        self.textFieldFavoritePlayer.text = self.user.userFavoritePlayer;
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userImagePath]];
        if (self.user.userId == [PUConnect sharedConnect].user.userId) {
            if (self.navigationController.viewControllers[0] == self) {
                self.barButtonItemSettings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(buttonSettingsTouchUpInside:)];
                self.barButtonItemDone = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(buttonDoneTouchUpInside:)];
                self.navigationItem.rightBarButtonItem = self.barButtonItemSettings;
            }
        } else {
            UIBarButtonItem *moreBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(buttonMoreTouchUpInside:)];
            self.navigationItem.rightBarButtonItem = moreBarButtonItem;
        }
        [self.tableViewSkills reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PUSkillCell *cell = (PUSkillCell *)[tableView dequeueReusableCellWithIdentifier:@"PUSkillCell" forIndexPath:indexPath];
    cell.skillType = indexPath.row + 2;
    NSArray *skills = [self.user.userSkills valueForKeyPath:@"@unionOfObjects.skillGameTypeId"];
    NSUInteger index = [skills indexOfObject:@(indexPath.row + 2)];
    cell.shouldShowSkillNotSet = self.user.userId != PUConnect.sharedConnect.user.userId;
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


#pragma mark - Actions methods

- (IBAction)buttonFollowersTouchUpInside:(id)sender {
    
    PUFollowersViewController *followersViewController = [[PUFollowersViewController alloc] initWithNibName:@"PUFollowersViewController" bundle:nil];
    followersViewController.user = self.user;
    [self.navigationController pushViewController:followersViewController animated:YES];
}

- (IBAction)buttonFollowingTouchUpInside:(id)sender {
    
    PUFollowingViewController *followingViewController = [[PUFollowingViewController alloc] initWithNibName:@"PUFollowingViewController" bundle:nil];
    followingViewController.user = self.user;
    [self.navigationController pushViewController:followingViewController animated:YES];
}

- (IBAction)buttonFindFriendsTouchUpInside:(id)sender {
    
    PUFindViewController *findViewController = [[PUFindViewController alloc] initWithNibName:@"PUFindViewController" bundle:nil];
    [self.navigationController pushViewController:findViewController animated:YES];
}

- (void)buttonSettingsTouchUpInside:(id)sender {
    
    UIActionSheet *actionSheetSettings = [[UIActionSheet alloc] initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit profile", @"Notifications", @"Logout", nil];
    [actionSheetSettings showFromBarButtonItem:sender animated:YES];
}

- (void)buttonDoneTouchUpInside:(id)sender {
    
    self.buttonImage.userInteractionEnabled = NO;
    self.textFieldUsername.userInteractionEnabled = NO;
    self.textFieldFullName.userInteractionEnabled = NO;
    self.textFieldHomePark.userInteractionEnabled = NO;
    self.textFieldFavoriteSport.userInteractionEnabled = NO;
    self.textFieldFavoriteTeams.userInteractionEnabled = NO;
    self.textFieldFavoritePlayer.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = self.barButtonItemSettings;
    [self.textFieldUsername resignFirstResponder];
    [self.textFieldFullName resignFirstResponder];
    [self.textFieldHomePark resignFirstResponder];
    [self.textFieldFavoriteSport resignFirstResponder];
    [self.textFieldFavoriteTeams resignFirstResponder];
    [self.textFieldFavoritePlayer resignFirstResponder];
    
    [self.hud show:YES];
    NSData *image = self.behaviourPhotoPicker.imagePicked ? UIImageJPEGRepresentation(self.imageViewUser.image, 1.0) : nil;
    [PUConnect.sharedConnect updateProfileWithUsername:self.textFieldUsername.text fullName:self.textFieldFullName.text homePark:self.textFieldHomePark.text favoriteSport:self.textFieldFavoriteSport.text favoriteTeams:self.textFieldFavoriteTeams.text favoritePlayer:self.textFieldFavoritePlayer.text facebookToken:nil image:image onSuccess:^(PUUser *user) {
        [self.hud hide:YES];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured and your profile was not updated. Please check your network connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        self.buttonImage.userInteractionEnabled = YES;
        self.textFieldUsername.userInteractionEnabled = YES;
        self.textFieldFullName.userInteractionEnabled = YES;
        self.textFieldHomePark.userInteractionEnabled = YES;
        self.textFieldFavoriteSport.userInteractionEnabled = YES;
        self.textFieldFavoriteTeams.userInteractionEnabled = YES;
        self.textFieldFavoritePlayer.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem = self.barButtonItemDone;
    }];
}

- (void)buttonMoreTouchUpInside:(id)sender {
    
    if (self.user.following) {
        if ([MFMailComposeViewController canSendMail]) {
            [[[UIActionSheet alloc] initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:@"Unfollow", @"Message", nil] showInView:self.view];
        } else {
            [[[UIActionSheet alloc] initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Unfollow", @"Message", nil] showInView:self.view];
        }
    } else {
        if ([MFMailComposeViewController canSendMail]) {
            [[[UIActionSheet alloc] initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:@"Follow", @"Message", nil] showInView:self.view];
        } else {
            [[[UIActionSheet alloc] initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Follow", @"Message", nil] showInView:self.view];
        }
    }
}


#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    if (result == MFMailComposeResultFailed) {
        [[[UIAlertView alloc] initWithTitle:@"Mail error" message:@"An error occured and your mail was not sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Logout"]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
            [[PUConnect sharedConnect] logout];
            PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:^{ }];
        }
    }
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:@"More"]) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Follow"]) {
            [PUConnect.sharedConnect followUser:self.user onCompletion:^(PUServerResponse serverResponseCode) {
                if (serverResponseCode == OK) {
                    self.user.following = YES;
                }
            }];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Unfollow"]) {
            [PUConnect.sharedConnect unfollowUser:self.user onCompletion:^(PUServerResponse serverResponseCode) {
                if (serverResponseCode == OK) {
                    self.user.following = NO;
                }
            }];
            
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report"]) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.navigationBar.tintColor = [UIColor whiteColor];
            mailComposeViewController.mailComposeDelegate = self;
            [mailComposeViewController.navigationBar setBarStyle:UIBarStyleBlack];
            //mailComposeViewController.toRecipients = @[@""];
            mailComposeViewController.subject = @"Report user";
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
            
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Message"]) {
            PUNewMessageViewController *newMessageViewController = [[PUNewMessageViewController alloc] initWithNibName:@"PUNewMessageViewController" bundle:nil];
            newMessageViewController.messeageToUser = self.user;
            [self.navigationController pushViewController:newMessageViewController animated:YES];
        }
    } else if ([actionSheet.title isEqualToString:@"Settings"]) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
            [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit profile"]) {
            self.buttonImage.userInteractionEnabled = YES;
            self.textFieldUsername.userInteractionEnabled = YES;
            self.textFieldFullName.userInteractionEnabled = YES;
            self.textFieldHomePark.userInteractionEnabled = YES;
            self.textFieldFavoriteSport.userInteractionEnabled = YES;
            self.textFieldFavoriteTeams.userInteractionEnabled = YES;
            self.textFieldFavoritePlayer.userInteractionEnabled = YES;
            self.navigationItem.rightBarButtonItem = self.barButtonItemDone;
            [self.textFieldUsername becomeFirstResponder];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Notifications"]) {
            PUNotificationsSettingsViewController *notificationsSettingsViewController = [[PUNotificationsSettingsViewController alloc] initWithNibName:@"PUNotificationsSettingsViewController" bundle:nil];
            notificationsSettingsViewController.user = self.user;
            [self.navigationController pushViewController:notificationsSettingsViewController animated:YES];
        }
    }
}


#pragma mark - PUSkillCellDelegate mehtods

- (void)cell:(UITableViewCell *)cell didAddSkillToUser:(PUUser *)user {
    
    self.user = user;
    [self.tableViewSkills reloadData];
}

@end
