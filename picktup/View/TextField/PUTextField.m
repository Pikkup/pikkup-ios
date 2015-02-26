//
//  PUTextField.m
//  picktup
//
//  Created by Planet 1107 on 19/09/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUTextField.h"

@implementation PUTextField

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    
    return CGRectInset(bounds, 10, 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
