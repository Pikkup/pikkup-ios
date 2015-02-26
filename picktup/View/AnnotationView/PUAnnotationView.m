//
//  PUAnnotationView.m
//  picktup
//
//  Created by Planet 1107 on 19/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUAnnotationView.h"

@implementation PUAnnotationView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self.imageViewAnnotationViewBackground pointInside:point withEvent:event]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeTouches) {
        if ([self.delegate respondsToSelector:@selector(touchUpInsideAnnotationView:)]) {
            [self.delegate touchUpInsideAnnotationView:self];
        }
    }
}


@end
