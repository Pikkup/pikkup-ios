//
//  PULoginViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PULoginViewController.h"
#import "PUAppDelegate.h"
#import <PNTToolbar/PNTToolbar.h>
#import <Accounts/Accounts.h>

@interface PULoginViewController ()

@end

@implementation PULoginViewController

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
    self.title = @"Login";
    PNTToolbar *toolbar = [PNTToolbar defaultToolbar];
    toolbar.mainScrollView = self.scrollViewLogin;
    toolbar.inputFields = @[self.textFieldUsername, self.textFieldPassword];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.scrollViewLogin.contentSize = CGSizeMake(CGRectGetWidth(self.scrollViewLogin.frame), CGRectGetHeight(self.scrollViewLogin.frame) +1.0f);
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods

- (IBAction)buttonLoginTouchUpInside:(id)sender {
    
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
    if ([self.textFieldUsername isFirstResponder]) {
        [self.textFieldUsername resignFirstResponder];
    }
    if ([self.textFieldPassword isFirstResponder]) {
        [self.textFieldPassword resignFirstResponder];
    }
    
    [self.hud show:YES];
    [[PUConnect sharedConnect] loginWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text onSuccess:^(PUUser *user) {
        [self.hud hide:NO];
        self.textFieldUsername.text = @"";
        self.textFieldPassword.text = @"";
        PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.sideViewController = [[PUSideViewController alloc] initWithNibName:@"PUSideViewController" bundle:nil];
        appDelegate.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:appDelegate.sideViewController.navigationControllers[0] leftViewController:appDelegate.sideViewController rightViewController:nil];
        appDelegate.viewDeckController.leftSize = 320 - 273;
        [appDelegate.window.rootViewController presentViewController:appDelegate.viewDeckController animated:YES completion:^{}];
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:NO];
    }];
}

- (IBAction)buttonLoginWithFacebookTouchUpInside:(id)sender {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookTypeAccount = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey : kFacebookAppId};
    [accountStore requestAccessToAccountsWithType:facebookTypeAccount options:options completion:^(BOOL granted, NSError *error) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if(granted){
                NSArray *accounts = [accountStore accountsWithAccountType:facebookTypeAccount];
                ACAccount *facebookAccount = accounts.firstObject;
                NSString *username = facebookAccount.username;
                NSString *token = @(username.hash).stringValue;
                
                [self.hud show:YES];
                [[PUConnect sharedConnect] loginWithFacebookToken:token onSuccess:^(PUUser *user) {
                    [self.hud hide:NO];
                    PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    appDelegate.sideViewController = [[PUSideViewController alloc] initWithNibName:@"PUSideViewController" bundle:nil];
                    appDelegate.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:appDelegate.sideViewController.navigationControllers[0] leftViewController:appDelegate.sideViewController rightViewController:nil];
                    appDelegate.viewDeckController.leftSize = 320 - 273;
                    [appDelegate.window.rootViewController presentViewController:appDelegate.viewDeckController animated:YES completion:^{}];
                } onFaliure:^(PUServerResponse serverResponseCode) {
                    [self.hud hide:NO];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occuerd, please try to register first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
                
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }];
}


@end
