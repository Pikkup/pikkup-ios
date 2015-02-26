//
//  PUSkillAlertContentView.m
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSkillAlertContentView.h"

@interface PUSkillAlertContentView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsStars;

@end

@implementation PUSkillAlertContentView

- (IBAction)buttonStarTouchUpInside:(UIButton *)sender {
    
    for (UIButton *button in self.buttonsStars) {
        if (button.tag <= sender.tag) {
            [button setImage:[UIImage imageNamed:@"star-full"] forState:UIControlStateNormal];
        } else {
            [button setImage:[UIImage imageNamed:@"star-empty"] forState:UIControlStateNormal];
        }
    }
    self.skillLevel = (int)sender.tag + 1;
}

@end
