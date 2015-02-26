//
//  PUAnnotationView.h
//  picktup
//
//  Created by Planet 1107 on 19/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PUAnnotationView;

@protocol PUAnnotationViewDelegate <NSObject>

- (void)touchUpInsideAnnotationView:(PUAnnotationView *)view;

@end

@interface PUAnnotationView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAnnotationViewBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) id<PUAnnotationViewDelegate>delegate;

@end
