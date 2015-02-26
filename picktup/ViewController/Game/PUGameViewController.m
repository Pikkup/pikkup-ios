//
//  PUGameViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUGameViewController.h"
#import "PUAppDelegate.h"
#import "PUParkViewController.h"
#import "PUAnnotationView.h"
#import "PUHostViewController.h"
#import "PUCreateParkViewController.h"
#import "PUCalloutView.h"
#import <PNTToolbar.h>
#import "PULobbyViewController.h"
#import <MapKit/MapKit.h>

@import MapKit;

@interface PUGameViewController () <MKMapViewDelegate, UITextFieldDelegate, PUCreateParkViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) IBOutlet MKMapView *mapViewGameLocation;
@property (strong, nonatomic) IBOutlet UITextField *textFieldStartDate;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEndDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerStartDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerEndDate;
@property (nonatomic) BOOL loading;
@property (strong, nonatomic) PUCalloutView *calloutView;
@property (nonatomic) BOOL mapRelocatedToUserLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation PUGameViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _events = [[NSMutableArray alloc] init];
        CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
        if (locationAuthorizationStatus != kCLAuthorizationStatusDenied) {
            self.locationManager = [[CLLocationManager alloc] init];
            //self.locationManager.delegate = self;
            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
                [self.locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
            }
        }
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Event Hub";
    
    if (self.navigationController.viewControllers.count == 1) {
        UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithTitle:@"Create game" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAddTouchUpInside:)];
        self.navigationItem.rightBarButtonItem = barButtonItemAdd;
    }

    [self.datePickerStartDate addTarget:self action:@selector(datePickerAction:) forControlEvents:UIControlEventAllEvents];
    [self.datePickerEndDate addTarget:self action:@selector(datePickerAction:) forControlEvents:UIControlEventAllEvents];
    self.textFieldStartDate.inputView = self.datePickerStartDate;
    self.textFieldEndDate.inputView = self.datePickerEndDate;
    
    PNTToolbar *toolbar = [PNTToolbar defaultToolbar];
    //toolbar.navigationButtonColor = [UIColor colorWithRed:43.0/255.0 green:142.0/255.0 blue:69.0/255.0 alpha:1.0];
    toolbar.inputFields = @[self.textFieldStartDate, self.textFieldEndDate];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    date = [calendar dateFromComponents:dateComponents];
    dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
    self.textFieldStartDate.text = [dateFormatter stringFromDate:date];
    self.textFieldEndDate.text = [dateFormatter stringFromDate:[date dateByAddingTimeInterval:24 * 60 * 60]];
    self.datePickerStartDate.date = date;
    self.datePickerEndDate.date = [date dateByAddingTimeInterval:24 * 60 * 60];
    
    if (self.mapRelocatedToUserLocation) {
        [self reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods

- (void)buttonAddTouchUpInside:(UIButton*)button {
    
    PUCreateParkViewController *createParkViewController = [[PUCreateParkViewController alloc] initWithNibName:@"PUCreateParkViewController" bundle:nil];
    createParkViewController.delegate = self;
    [self.navigationController pushViewController:createParkViewController animated:YES];
}

- (IBAction)buttonQuickmatchTouchUpInside:(id)sender {
    
    if (self.events.count) {
        PUEvent *event = self.events[(arc4random() % self.events.count)];
        PULobbyViewController *lobbyViewController = [[PULobbyViewController alloc] initWithNibName:@"PULobbyViewController" bundle:nil];
        lobbyViewController.event = event;
        [self.navigationController pushViewController:lobbyViewController animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No matches found" message:@"Please try to change your location or game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)datePickerAction:(UIDatePicker *)datePicker {
    
    if (datePicker == self.datePickerEndDate) {
        self.datePickerStartDate.maximumDate = self.datePickerEndDate.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
        self.textFieldEndDate.text = [dateFormatter stringFromDate:self.datePickerEndDate.date];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
        self.textFieldStartDate.text = [dateFormatter stringFromDate:self.datePickerStartDate.date];
    }
}


#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    @synchronized (self) {
        if (!self.mapRelocatedToUserLocation && CLLocationCoordinate2DIsValid(userLocation.coordinate) && [userLocation.location.timestamp timeIntervalSinceNow] < 400) {
            self.mapRelocatedToUserLocation = YES;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
            [self.mapViewGameLocation setRegion:region animated:YES];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    } else {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"pin-custom"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    PUEvent *annotation = view.annotation;
    if ([annotation isKindOfClass:PUEvent.class]) {
        PUParkViewController *parkViewController = [[PUParkViewController alloc] initWithNibName:@"PUParkViewController" bundle:nil];
        parkViewController.park = annotation.park;
        [self.navigationController pushViewController:parkViewController animated:YES];
    }
}

- (void)reloadOnUserLocation {
    
    self.mapRelocatedToUserLocation = YES;
    MKUserLocation *userLocation = self.mapViewGameLocation.userLocation;
    if (userLocation && CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
        [self.mapViewGameLocation setRegion:region animated:YES];
    }
}

- (void)reloadData {
    
    @synchronized(self) {
        if (!_loading) {
            _loading = YES;
            [self.hud show:YES];
            [[PUConnect sharedConnect] eventsWithEventType:self.eventType latitude:self.mapViewGameLocation.centerCoordinate.latitude longitude:self.mapViewGameLocation.centerCoordinate.longitude radius:5000 startDate:self.datePickerStartDate.date endDate:self.datePickerEndDate.date onSuccess:^(NSMutableArray *parks) {
                [self.hud hide:NO];
                _loading = NO;
                [self.events removeAllObjects];
                [self.events addObjectsFromArray:parks];
                if (self.mapViewGameLocation.annotations.count) {
                    [self.mapViewGameLocation removeAnnotations:self.mapViewGameLocation.annotations];
                }
                if (self.events.count) {
                    [self.mapViewGameLocation addAnnotations:self.events];
                }
            } onFaliure:^(PUServerResponse serverResponseCode) {
                [self.hud hide:NO];
                _loading = NO;
            }];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    self.calloutView.alpha = 0.0f;
    if (self.calloutView.superview != self.mapViewGameLocation) {
        [self.mapViewGameLocation addSubview:self.calloutView];
    }
    [self.mapViewGameLocation bringSubviewToFront:self.calloutView];
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.calloutView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
    [self reloadData];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    [self.calloutView removeFromSuperview];
    [self.mapViewGameLocation setCenterCoordinate:view.annotation.coordinate animated:YES];
    if ([view.annotation isKindOfClass:PUEvent.class]) {
        self.calloutView = [[NSBundle mainBundle] loadNibNamed:@"PUCalloutView" owner:self options:nil].firstObject;
        [self.calloutView.buttonAccessory addTarget:self action:@selector(buttonAccessoryTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.calloutView.event = (PUEvent *)view.annotation;
        self.calloutView.center = (CGPoint){CGRectGetWidth(view.superview.frame) / 2, CGRectGetHeight(view.superview.frame) / 2 - 50};
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    if (self.calloutView.superview == self.mapViewGameLocation) {
        [self.calloutView removeFromSuperview];
        self.calloutView = nil;
    }
}

- (void)buttonAccessoryTouchUpInside:(UIButton *)button {

    PUCalloutView *calloutView = (PUCalloutView *)button.superview;
    PUEvent *annotation = calloutView.event;
    if ([annotation isKindOfClass:PUEvent.class]) {
        PUParkViewController *parkViewController = [[PUParkViewController alloc] initWithNibName:@"PUParkViewController" bundle:nil];
        parkViewController.park = annotation.park;
        [self.navigationController pushViewController:parkViewController animated:YES];
    }
}


#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
    if (textField.text.length) {
        NSDate *date = [dateFormatter dateFromString:textField.text];
        NSDate *now = [NSDate date];
        if (date &&  [date timeIntervalSinceDate:now] >= 0) {
            if (textField == self.textFieldStartDate) {
                self.datePickerStartDate.date = date;
            } else {
                self.datePickerEndDate.date = date;
            }
        }
    }
}


#pragma mark - PUCreateParkViewControllerDelegate methods

- (void)parkCreated:(PUPark*)createdPark {
    
    [self.navigationController popViewControllerAnimated:NO];
    PUParkViewController *parkViewController = [[PUParkViewController alloc] initWithNibName:@"PUParkViewController" bundle:nil];
    parkViewController.park = createdPark;
    [self.navigationController pushViewController:parkViewController animated:YES];
}

@end
