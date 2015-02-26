//
//  PURegisterViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PURegisterViewController.h"
#import "PUAppDelegate.h"
#import <PNTToolbar/PNTToolbar.h>
#import "PUGlobalDefines.h"
#import <Accounts/Accounts.h>
#import <CoreLocation/CoreLocation.h>


@interface PURegisterViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewRegister;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFullName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldRePassword;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation PURegisterViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Register";
    PNTToolbar *toolbar = [PNTToolbar defaultToolbar];
    toolbar.mainScrollView = self.scrollViewRegister;
    toolbar.inputFields = @[self.textFieldUsername, self.textFieldFullName, self.textFieldPassword, self.textFieldRePassword];
    
    CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
    if (locationAuthorizationStatus != kCLAuthorizationStatusDenied) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            [self.locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
        } else {
            [self.locationManager startUpdatingLocation];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.scrollViewRegister.contentSize = CGSizeMake(CGRectGetWidth(self.scrollViewRegister.frame), CGRectGetHeight(self.scrollViewRegister.frame) +1.0f);
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender {
    
    if (self.imageViewUser.image) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            [[[UIActionSheet alloc] initWithTitle:@"User image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove image" otherButtonTitles:@"Take image", @"Choose image", nil] showInView:self.view];
        } else {
            [[[UIActionSheet alloc] initWithTitle:@"User image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove image" otherButtonTitles:@"Choose image", nil] showInView:self.view];
        }
    } else {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            [[[UIActionSheet alloc] initWithTitle:@"User image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take image", @"Choose image", nil] showInView:self.view];
        } else {
            [[[UIActionSheet alloc] initWithTitle:@"User image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose image", nil] showInView:self.view];
        }
    }
}

- (IBAction)buttonRegisterWithFacebookTouchUpInside:(id)sender {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookTypeAccount = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [accountStore requestAccessToAccountsWithType:facebookTypeAccount options:@{ACFacebookAppIdKey: kFacebookAppId} completion:^(BOOL granted, NSError *error) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if(granted){
                NSArray *accounts = [accountStore accountsWithAccountType:facebookTypeAccount];
                ACAccount *facebookAccount = accounts.firstObject;
                NSString *username = facebookAccount.username;
                NSString *fullName = [facebookAccount valueForKey:@"properties"][@"ACPropertyFullName"];
                NSString *token = @(username.hash).stringValue;
                
                [self.hud show:YES];
                CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
                [[PUConnect sharedConnect] registerWithUsername:username fullName:fullName password:nil facebookToken:token  latitude:coordinate.latitude longitude:coordinate.longitude  image:nil onSuccess:^(PUUser *user) {
                    [self.hud hide:NO];
                    PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    appDelegate.sideViewController = [[PUSideViewController alloc] initWithNibName:@"PUSideViewController" bundle:nil];
                    appDelegate.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:appDelegate.sideViewController.navigationControllers[0] leftViewController:appDelegate.sideViewController rightViewController:nil];
                    appDelegate.viewDeckController.leftSize = 320 - 273;
                    [appDelegate.window.rootViewController presentViewController:appDelegate.viewDeckController animated:YES completion:^{ }];
                } onFaliure:^(PUServerResponse serverResponseCode) {
                    [self.hud hide:NO];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occuerd, please check your network connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
                
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }];
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {
    
    if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Input" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (![self.textFieldUsername isFirstResponder]) {
            [self.textFieldUsername becomeFirstResponder];
        }
        return;
    }
    if (!self.textFieldPassword.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Input" message:@"Password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (![self.textFieldPassword isFirstResponder]) {
            [self.textFieldPassword becomeFirstResponder];
        }
        return;
    }
    if (!self.textFieldRePassword.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Input" message:@"Repeat password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (![self.textFieldRePassword isFirstResponder]) {
            [self.textFieldRePassword becomeFirstResponder];
        }
        return;
    }
    if (![self.textFieldPassword.text isEqualToString:self.textFieldRePassword.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Input" message:@"Password and repeated password do not match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (![self.textFieldPassword isFirstResponder]) {
            [self.textFieldPassword becomeFirstResponder];
        }
        return;
    }
    if ([self.textFieldUsername isFirstResponder]) {
        [self.textFieldUsername resignFirstResponder];
    }
    if ([self.textFieldFullName isFirstResponder]) {
        [self.textFieldFullName resignFirstResponder];
    }
    if ([self.textFieldPassword isFirstResponder]) {
        [self.textFieldPassword resignFirstResponder];
    }
    if ([self.textFieldRePassword isFirstResponder]) {
        [self.textFieldRePassword resignFirstResponder];
    }
    
    [self.hud show:YES];
    CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
    [[PUConnect sharedConnect] registerWithUsername:self.textFieldUsername.text fullName:self.textFieldFullName.text password:self.textFieldPassword.text facebookToken:nil latitude:coordinate.latitude longitude:coordinate.longitude image:UIImageJPEGRepresentation(self.imageViewUser.image, 0.5) onSuccess:^(PUUser *user) {
        [self.hud hide:NO];
        self.textFieldUsername.text = @"";
        self.textFieldFullName.text = @"";
        self.textFieldPassword.text = @"";
        self.textFieldRePassword.text = @"";
        PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.sideViewController = [[PUSideViewController alloc] initWithNibName:@"PUSideViewController" bundle:nil];
        appDelegate.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:appDelegate.sideViewController.navigationControllers[0] leftViewController:appDelegate.sideViewController rightViewController:nil];
        appDelegate.viewDeckController.leftSize = 320 - 273;
        [appDelegate.window.rootViewController presentViewController:appDelegate.viewDeckController animated:YES completion:^{ }];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:NO];
    }];
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:@"User image"]) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"Take image"]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        } else if ([buttonTitle isEqualToString:@"Choose image"]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        } else if ([buttonTitle isEqualToString:@"Remove image"]) {
            self.imageViewUser.image = nil;
        }
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];;
    self.imageViewUser.image = originalImage;
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    
}

@end
