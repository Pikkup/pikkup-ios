//
//  PUCommentCell.m
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUCommentCell.h"
#import "PUConnect.h"

@implementation PUCommentCell

- (void)awakeFromNib {
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)sharedCell {
    
    static PUCommentCell *sharedCell = nil;
    if (sharedCell) {
        return sharedCell;
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedCell = [[NSBundle mainBundle] loadNibNamed:@"PUCommentCell" owner:nil options:nil].firstObject;
        });
        return sharedCell;
    }
}

- (void)reloadDataAllowDownload:(BOOL)allowDownload {
    
    if (self.comment) {
        
        [self.labelDate setTextWithDate:self.comment.commentDate updateInterval:15];
        self.labelComment.text = self.comment.commentText;
        self.labelComment.frame = CGRectMake(0.0f, CGRectGetMinY(self.labelComment.frame), 186.0f, 21.0f);
        [self.labelComment sizeToFit];
        
        PUUser *user = self.comment.user;
        
        if (user.userId == [PUConnect sharedConnect].user.userId) {
            self.imageViewUserImage.frame = CGRectMake(252.0f, CGRectGetMinY(self.imageViewUserImage.frame), CGRectGetWidth(self.imageViewUserImage.frame), CGRectGetHeight(self.imageViewUserImage.frame));
            self.imageViewUserOverlay.frame = CGRectMake(252.0f, CGRectGetMinY(self.imageViewUserOverlay.frame), CGRectGetWidth(self.imageViewUserOverlay.frame), CGRectGetHeight(self.imageViewUserOverlay.frame));
            
            if (CGRectGetHeight(self.labelComment.frame) > 20.0f) {
                self.labelComment.frame = CGRectMake(CGRectGetMinX(self.imageViewUserImage.frame) -27.0f -CGRectGetWidth(self.labelComment.frame), CGRectGetMinY(self.labelComment.frame), CGRectGetWidth(self.labelComment.frame), CGRectGetHeight(self.labelComment.frame));
            } else {
                self.labelComment.frame = CGRectMake(CGRectGetMinX(self.imageViewUserImage.frame) -27.0f -CGRectGetWidth(self.labelComment.frame), CGRectGetMinY(self.labelComment.frame), CGRectGetWidth(self.labelComment.frame), 20.0f);
            }
            self.labelComment.textAlignment = NSTextAlignmentRight;
            
            self.imageViewMessageBackground.image = [[UIImage imageNamed:@"conversation_me_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 20.0f, 15.0f, 20.0f) resizingMode:UIImageResizingModeStretch];
            
        } else {
            self.imageViewUserImage.frame = CGRectMake(20.0f, CGRectGetMinY(self.imageViewUserImage.frame), CGRectGetWidth(self.imageViewUserImage.frame), CGRectGetHeight(self.imageViewUserImage.frame));
            self.imageViewUserOverlay.frame = CGRectMake(20.0f, CGRectGetMinY(self.imageViewUserOverlay.frame), CGRectGetWidth(self.imageViewUserOverlay.frame), CGRectGetHeight(self.imageViewUserOverlay.frame));
            
            if (CGRectGetHeight(self.labelComment.frame) > 20.0f) {
                self.labelComment.frame = CGRectMake(CGRectGetMaxX(self.imageViewUserImage.frame) +27.0f, CGRectGetMinY(self.labelComment.frame), CGRectGetWidth(self.labelComment.frame), CGRectGetHeight(self.labelComment.frame));
            } else {
                self.labelComment.frame = CGRectMake(CGRectGetMaxX(self.imageViewUserImage.frame) +27.0f, CGRectGetMinY(self.labelComment.frame), CGRectGetWidth(self.labelComment.frame), 20.0f);
            }
            self.labelComment.textAlignment = NSTextAlignmentLeft;
            
            self.imageViewMessageBackground.image = [[UIImage imageNamed:@"conversation_user_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 20.0f, 15.0f, 20.0f) resizingMode:UIImageResizingModeStretch];
        }
        
        self.imageViewMessageBackground.frame = CGRectMake(CGRectGetMinX(self.labelComment.frame) -20.0f, CGRectGetMinY(self.imageViewMessageBackground.frame), CGRectGetWidth(self.labelComment.frame) +40.0f, CGRectGetHeight(self.labelComment.frame) +14.0f);
        [self.imageViewUserImage setImageWithURL:[NSURL URLWithString:user.userSmallImagePath]];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self reloadDataAllowDownload:YES];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.labelComment.frame = CGRectMake(CGRectGetMinX(self.labelComment.frame), CGRectGetMinY(self.labelComment.frame), 186.0f, 21.0f);
    [self.imageViewUserImage cancelImageRequestOperation];
    self.imageViewUserImage.image = [UIImage imageNamed:@"avatar-overlay"];
}


+ (float)heightWithComment:(PUComment *)comment {
    
    PUCommentCell *cell = [PUCommentCell sharedCell];
    cell.comment = comment;
    [cell reloadDataAllowDownload:NO];
    float height = CGRectGetMaxY(cell.labelComment.frame) + 18.0f;
    return MAX(height, 81);
}

@end
