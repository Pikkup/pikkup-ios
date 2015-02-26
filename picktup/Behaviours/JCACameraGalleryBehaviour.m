//
//  JCACameraGalleryBehaviour.m
//  picktup
//
//  Created by Josip Cavar on 22/07/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "JCACameraGalleryBehaviour.h"

@interface JCACameraGalleryBehaviour () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPickedImage;
@property (assign, nonatomic, readwrite) BOOL imagePicked;

@end

@implementation JCACameraGalleryBehaviour

- (IBAction)presentOptions {
    
    UIActionSheet *actionSheetOptions = [[UIActionSheet alloc] initWithTitle:@"Choose source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil];
    [actionSheetOptions showInView:self.owner.view];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    UIImagePickerControllerSourceType sourceType;
    if (buttonIndex == 0) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 1) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        imagePickerController.sourceType = sourceType;
        [self.owner presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Source type not available on this device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imageViewPickedImage.image = info[UIImagePickerControllerOriginalImage];
    self.imagePicked = YES;
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}


@end
