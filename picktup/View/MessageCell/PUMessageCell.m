//
//  PUMessageTableViewCell.m
//  picktup
//
//  Created by Josip Cavar on 26/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUMessageCell.h"
#import "PUConnect.h"

@interface PUMessageCell ()

@property (strong, nonatomic) IBOutlet NVDateLabel *labelDate;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUserImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUserOverlay;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewMessageBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;

@end

@implementation PUMessageCell

- (void)awakeFromNib {
    
    // Initialization code
}


+ (instancetype)sharedCell {
    
    static PUMessageCell *sharedCell = nil;
    if (sharedCell) {
        return sharedCell;
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedCell = [[NSBundle mainBundle] loadNibNamed:@"PUMessageCell" owner:nil options:nil].firstObject;
        });
        return sharedCell;
    }
}

- (void)reloadDataAllowDownload:(BOOL)allowDownload {
    
    if (self.message) {
        //[self.labelDate setTextWithDate:self.message.messageDate updateInterval:15];
        self.labelDate.text = self.message.messageTimeAgo;
        self.labelMessage.text = self.message.messageText;
        self.labelMessage.frame = CGRectMake(0.0f, CGRectGetMinY(self.labelMessage.frame), 186.0f, 21.0f);
        [self.labelMessage sizeToFit];
        
        PUUser *user = self.message.userFrom;
        
        if (user.userId == [PUConnect sharedConnect].user.userId) {
            self.imageViewUserImage.frame = CGRectMake(252.0f, CGRectGetMinY(self.imageViewUserImage.frame), CGRectGetWidth(self.imageViewUserImage.frame), CGRectGetHeight(self.imageViewUserImage.frame));
            self.imageViewUserOverlay.frame = CGRectMake(252.0f, CGRectGetMinY(self.imageViewUserOverlay.frame), CGRectGetWidth(self.imageViewUserOverlay.frame), CGRectGetHeight(self.imageViewUserOverlay.frame));
            
            if (CGRectGetHeight(self.labelMessage.frame) > 20.0f) {
                self.labelMessage.frame = CGRectMake(CGRectGetMinX(self.imageViewUserImage.frame) -27.0f -CGRectGetWidth(self.labelMessage.frame), CGRectGetMinY(self.labelMessage.frame), CGRectGetWidth(self.labelMessage.frame), CGRectGetHeight(self.labelMessage.frame));
            } else {
                self.labelMessage.frame = CGRectMake(CGRectGetMinX(self.imageViewUserImage.frame) -27.0f -CGRectGetWidth(self.labelMessage.frame), CGRectGetMinY(self.labelMessage.frame), CGRectGetWidth(self.labelMessage.frame), 20.0f);
            }
            self.labelMessage.textAlignment = NSTextAlignmentRight;
            
            self.imageViewMessageBackground.image = [[UIImage imageNamed:@"conversation_me_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 20.0f, 15.0f, 20.0f) resizingMode:UIImageResizingModeStretch];
            
        } else {
            self.imageViewUserImage.frame = CGRectMake(20.0f, CGRectGetMinY(self.imageViewUserImage.frame), CGRectGetWidth(self.imageViewUserImage.frame), CGRectGetHeight(self.imageViewUserImage.frame));
            self.imageViewUserOverlay.frame = CGRectMake(20.0f, CGRectGetMinY(self.imageViewUserOverlay.frame), CGRectGetWidth(self.imageViewUserOverlay.frame), CGRectGetHeight(self.imageViewUserOverlay.frame));
            
            if (CGRectGetHeight(self.labelMessage.frame) > 20.0f) {
                self.labelMessage.frame = CGRectMake(CGRectGetMaxX(self.imageViewUserImage.frame) +27.0f, CGRectGetMinY(self.labelMessage.frame), CGRectGetWidth(self.labelMessage.frame), CGRectGetHeight(self.labelMessage.frame));
            } else {
                self.labelMessage.frame = CGRectMake(CGRectGetMaxX(self.imageViewUserImage.frame) +27.0f, CGRectGetMinY(self.labelMessage.frame), CGRectGetWidth(self.labelMessage.frame), 20.0f);
            }
            self.labelMessage.textAlignment = NSTextAlignmentLeft;
            
            self.imageViewMessageBackground.image = [[UIImage imageNamed:@"conversation_user_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 20.0f, 15.0f, 20.0f) resizingMode:UIImageResizingModeStretch];
        }
        
        self.imageViewMessageBackground.frame = CGRectMake(CGRectGetMinX(self.labelMessage.frame) -20.0f, CGRectGetMinY(self.imageViewMessageBackground.frame), CGRectGetWidth(self.labelMessage.frame) +40.0f, CGRectGetHeight(self.labelMessage.frame) +14.0f);
        [self.imageViewUserImage setImageWithURL:[NSURL URLWithString:user.userSmallImagePath]];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self reloadDataAllowDownload:YES];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.labelMessage.frame = CGRectMake(CGRectGetMinX(self.labelMessage.frame), CGRectGetMinY(self.labelMessage.frame), 186.0f, 21.0f);
    [self.imageViewUserImage cancelImageRequestOperation];
    self.imageViewUserImage.image = [UIImage imageNamed:@"avatar-overlay"];
}


+ (float)heightWithMessage:(PUMessage *)message {
    
    PUMessageCell *cell = [PUMessageCell sharedCell];
    cell.message = message;
    [cell reloadDataAllowDownload:NO];
    float height = CGRectGetMaxY(cell.labelMessage.frame) +18.0f;
    return MAX(height, 81);
}

@end
