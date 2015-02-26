//
//  PUUserCell.m
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUUserCell.h"
#import "PUSkill.h"

@implementation PUUserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (self.user) {
        self.labelUserName.text = self.user.username;
        NSUInteger index = [self.user.userSkills indexOfObjectPassingTest:^BOOL(PUSkill *skill, NSUInteger idx, BOOL *stop) {
            if (skill.skillGameTypeId == self.eventType) {
                return YES;
            } else {
                return NO;
            }
        }];
        if (index != NSNotFound) {
            PUSkill *skill = self.user.userSkills[index];
            for (UIImageView *imageView in self.imageViewsStars) {
                if (imageView.tag < skill.skillLevel) {
                    [imageView setImage:[UIImage imageNamed:@"star-full"]];
                } else {
                    [imageView setImage:[UIImage imageNamed:@"star-empty"]];
                }
            }
        } else {
            for (UIImageView *imageView in self.imageViewsStars) {
                [imageView setImage:[UIImage imageNamed:@"star-empty"]];
            }
        }

    }
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (IBAction)buttonUsernameTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(cell:didTouchUpInsideUserButton:)]) {
        [self.delegate cell:self didTouchUpInsideUserButton:sender];
    }

}

@end
