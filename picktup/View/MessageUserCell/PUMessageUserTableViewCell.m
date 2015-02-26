//
//  PUMessageUserTableViewCell.m
//  picktup
//
//  Created by Josip Cavar on 26/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUMessageUserTableViewCell.h"
#import "PUConnect.h"

@interface PUMessageUserTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUserImage;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;

@end

@implementation PUMessageUserTableViewCell

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.imageViewUserImage.image = [UIImage imageNamed:@"avatar-overlay-small"];
}

+ (instancetype)sharedCell {
    
    static PUMessageUserTableViewCell *sharedCell = nil;
    if (sharedCell) {
        return sharedCell;
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedCell = [[NSBundle mainBundle] loadNibNamed:@"PUMessageUserTableViewCell" owner:nil options:nil].firstObject;
        });
        return sharedCell;
    }
}

- (void)reloadDataAllowDownload:(BOOL)allowDownload {
    
    if (self.message) {
        self.labelDate.text = self.message.messageTimeAgo;
        self.labelMessage.text = self.message.messageText;
        
        PUUser *user;
        if ([PUConnect sharedConnect].user.userId == self.message.userFrom.userId) {
            user = self.message.userTo;
        } else {
            user = self.message.userFrom;
        }
        self.labelUsername.text = user.userFullName;
        [self.imageViewUserImage setImageWithURL:[NSURL URLWithString:user.userSmallImagePath]];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (self.message) {
        [self reloadDataAllowDownload:YES];
    }
}

@end
