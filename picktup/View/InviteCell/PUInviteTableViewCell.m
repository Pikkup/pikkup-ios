//
//  PUInviteTableViewCell.m
//  picktup
//
//  Created by Josip Cavar on 04/09/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUInviteTableViewCell.h"
#import "PUInvite.h"
#import "PUConnect.h"

@interface PUInviteTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelInvite;
@property (weak, nonatomic) IBOutlet UIButton *buttonAccept;
@property (weak, nonatomic) IBOutlet UIButton *buttonDecline;

@end

@implementation PUInviteTableViewCell

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)setInvite:(PUInvite *)invite {

    _invite = invite;
    [self layoutSubviews];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.labelInvite.text = [NSString stringWithFormat:@"Invite from %@ for event %@", self.invite.fromUser.username, self.invite.event.eventName];
    if (self.invite.inviteStatusId == 2) {
        self.buttonAccept.alpha = 0.0f;
        self.buttonDecline.alpha = 0.0f;
        self.backgroundColor = [UIColor greenColor];
    } else if (self.invite.inviteStatusId == 3) {
        self.buttonAccept.alpha = 0.0f;
        self.buttonDecline.alpha = 0.0f;
        self.backgroundColor = [UIColor redColor];
    } else {
        self.buttonAccept.alpha = 1.0f;
        self.buttonDecline.alpha = 1.0f;
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)buttonAcceptTouchUpInside:(id)sender {
    
    self.invite.inviteStatusId = 2;
    [self layoutSubviews];
    [PUConnect.sharedConnect setInviteStatusForInviteWithId:@(self.invite.inviteId).stringValue status:@"2" onSuccess:^(int inviteStatusID) {
        self.invite.inviteStatusId = inviteStatusID;
        [self layoutSubviews];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error has occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (IBAction)buttonDeclineTouchUpInside:(id)sender {
    
    self.invite.inviteStatusId = 3;
    [self layoutSubviews];
    [PUConnect.sharedConnect setInviteStatusForInviteWithId:@(self.invite.inviteId).stringValue status:@"3" onSuccess:^(int inviteStatusID) {
        self.invite.inviteStatusId = inviteStatusID;
        [self layoutSubviews];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error has occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

@end
