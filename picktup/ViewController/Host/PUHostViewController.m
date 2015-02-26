//
//  PUHostViewController.m
//  picktup
//
//  Created by Planet 1107 on 07/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUHostViewController.h"
#import "PULobbyViewController.h"
#import "PUInviteViewController.h"
#import <PNTToolbar.h>

@interface PUHostViewController () <PUInviteViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerStartDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerEndDate;
@property (strong, nonatomic) IBOutlet UITextField *textFieldGame;
@property (strong, nonatomic) IBOutlet UITextField *textFieldDateStart;
@property (strong, nonatomic) IBOutlet UITextField *textFieldDateEnd;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPark;
@property (strong, nonatomic) IBOutlet UITextField *textFieldMaxPlayers;
@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewHost;
@property (strong, nonatomic) IBOutlet UIView *viewContentHost;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewGame;

@property (strong, nonatomic) NSArray *games;
@property (strong, nonatomic) NSArray *peopleInvited;

@end

@implementation PUHostViewController

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
    self.title = @"Host game";
    [self.scrollViewHost addSubview:self.viewContentHost];
    self.scrollViewHost.contentSize = self.viewContentHost.frame.size;
    self.textFieldDateStart.inputView = self.datePickerStartDate;
    self.textFieldDateEnd.inputView = self.datePickerEndDate;
    self.textFieldGame.inputView = self.pickerViewGame;
    PNTToolbar *toolbar = [PNTToolbar defaultToolbar];
    //toolbar.navigationButtonColor = [UIColor colorWithRed:43.0/255.0 green:142.0/255.0 blue:69.0/255.0 alpha:1.0];
    toolbar.mainScrollView = self.scrollViewHost;
    toolbar.inputFields = @[self.textFieldGame, self.textFieldDateStart, self.textFieldDateEnd, self.textFieldPark, self.textFieldMaxPlayers, self.textViewDescription];
    
    self.textFieldPark.text = self.park.title;
    self.textFieldGame.text = @"Soccer";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
    NSDate *date = [NSDate date];
    self.textFieldDateStart.text = [dateFormatter stringFromDate:date];
    self.textFieldDateEnd.text = [dateFormatter stringFromDate:[date dateByAddingTimeInterval:60 * 60]];
    self.datePickerStartDate.date = date;
    self.datePickerStartDate.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePickerEndDate.date = [date dateByAddingTimeInterval:60 * 60];
    self.datePickerEndDate.datePickerMode = UIDatePickerModeDateAndTime;
    
    self.games = kPUGames;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods

- (void)buttonBackTouchUpInside:(UIButton*)button {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)buttonLobbyTouchUpInside:(id)sender {
    
    if (self.textFieldMaxPlayers.text.length && self.textFieldMaxPlayers.text.integerValue > 0 && self.datePickerStartDate.date && self.datePickerEndDate.date) {
        [self.hud show:YES];
        PUEventType eventType = [self.games indexOfObject:self.textFieldGame.text] + 2;
        [[PUConnect sharedConnect] addEventWithEventType:eventType description:self.textViewDescription.text maxPlayers:self.textFieldMaxPlayers.text.integerValue startDate:self.datePickerStartDate.date endDate:self.datePickerEndDate.date toPark:self.park onSuccess:^(PUEvent *event) {
            [self.hud hide:NO];
            [[PUConnect sharedConnect] joinEvent:event onCompletion:^(PUServerResponse serverResponseCode) {
                for (PUUser *user in self.peopleInvited) {
                    [PUConnect.sharedConnect sendInviteToUser:user forEvent:event onSuccess:^{
                        
                    } onFaliure:^(PUServerResponse serverResponseCode) {
                        
                    }];
                }
            }];
            if ([self.delegate respondsToSelector:@selector(addedEvent:)]) {
                [self.delegate addedEvent:event];
            }
        } onFaliure:^(PUServerResponse serverResponseCode) {
            [self.hud hide:NO];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured and event was not created, please check your network connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Missing input" message:@"All fields are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)buttonFriendsTouchUpInside:(id)sender {
    
    PUInviteViewController *inviteViewController = [[PUInviteViewController alloc] initWithNibName:@"PUInviteViewController" bundle:nil];
    inviteViewController.delegate = self;
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (IBAction)datePickerAction:(UIDatePicker *)datePicker {
    
    if (datePicker == self.datePickerStartDate) {
        if (self.datePickerStartDate.date) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
            self.textFieldDateStart.text = [dateFormatter stringFromDate:self.datePickerStartDate.date];
            
            if ([self.datePickerStartDate.date timeIntervalSinceDate:self.datePickerEndDate.date] > 0) {
                self.datePickerEndDate.date = [self.datePickerStartDate.date dateByAddingTimeInterval:3600];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
                self.textFieldDateEnd.text = [dateFormatter stringFromDate:self.datePickerEndDate.date];
            }
        } else {
            self.textFieldDateStart.text = @"";
        }
    } else {
        if (self.datePickerEndDate.date) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
            self.textFieldDateEnd.text = [dateFormatter stringFromDate:self.datePickerEndDate.date];
        } else {
            self.textFieldDateEnd.text = @"";
        }
    }
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.games[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.textFieldGame.text = self.games[row];
}


#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.games.count;
}


#pragma mark - PUInviteViewControllerDelegate methods

- (void)invitedUsers:(NSArray*)users {
    
    self.peopleInvited = users;
}

@end
