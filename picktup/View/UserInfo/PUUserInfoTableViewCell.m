//
//  PUUserInfoTableViewCell.m
//  picktup
//
//  Created by Planet 1107 on 21/07/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUUserInfoTableViewCell.h"
#import "PUUser.h"
#import "UIImageView+AFNetworking.h"
#import "PUConnect.h"

@interface PUUserInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAvtar;
@property (weak, nonatomic) IBOutlet UIButton *buttonFollowUnfollow;

@end

@implementation PUUserInfoTableViewCell

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.imageViewAvtar.image = [UIImage imageNamed:@"avatar-overlay-small"];
}

- (void)setUser:(PUUser *)user {
    
    _user = user;
    if (self.user) {
        self.labelUsername.text = self.user.userFullName;
        [self.imageViewAvtar setImageWithURL:[NSURL URLWithString:user.userSmallImagePath]];
        self.buttonFollowUnfollow.hidden = !self.shouldShowFollowUnfollowButton;
        if (self.user.following) {
            [self.buttonFollowUnfollow setTitle:@"Unfollow" forState:UIControlStateNormal];
        } else {
            [self.buttonFollowUnfollow setTitle:@"Follow" forState:UIControlStateNormal];
        }
        
        if (self.user.userId == PUConnect.sharedConnect.user.userId) {
            self.buttonFollowUnfollow.hidden = YES;
        }

    }
}

- (void)setShouldShowFollowUnfollowButton:(BOOL)shouldShowFollowUnfollowButton {

    _shouldShowFollowUnfollowButton = shouldShowFollowUnfollowButton;
    self.buttonFollowUnfollow.hidden = !self.shouldShowFollowUnfollowButton;
    if (self.user.userId == PUConnect.sharedConnect.user.userId) {
        self.buttonFollowUnfollow.hidden = YES;
    }
}

- (IBAction)buttonFollowUnfollowTouchUpInside:(id)sender {
    
    if (self.user.following) {
        [PUConnect.sharedConnect unfollowUser:self.user onCompletion:^(PUServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                self.user.following = NO;
                [self.buttonFollowUnfollow setTitle:@"Follow" forState:UIControlStateNormal];
            }
        }];
    } else {
        [PUConnect.sharedConnect followUser:self.user onCompletion:^(PUServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                self.user.following = YES;
                [self.buttonFollowUnfollow setTitle:@"Unfollow" forState:UIControlStateNormal];
            }
        }];
    }
}

@end
