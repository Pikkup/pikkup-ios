//
//  PUCreateGameViewController.m
//  picktup
//
//  Created by Planet 1107 on 20/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUCreateParkViewController.h"
#import "PUParkViewController.h"
#import "PUAnnotationView.h"
#import "PUHostViewController.h"
#import "PULobbyViewController.h"

@import MapKit;

@interface PUCreateParkViewController () <UIAlertViewDelegate, PUAnnotationViewDelegate, PUHostViewControllerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapViewCreateGame;
@property (strong, nonatomic) PUAnnotationView *annotationView;
@property (strong, nonatomic) CLPlacemark *currentPlacemark;
@property (nonatomic) BOOL mapRelocatedToUserLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation PUCreateParkViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
        if (locationAuthorizationStatus != kCLAuthorizationStatusDenied) {
            self.locationManager = [[CLLocationManager alloc] init];
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
    self.title = @"Park location";
    self.annotationView = [[NSBundle mainBundle] loadNibNamed:@"PUAnnotationView" owner:self options:nil].firstObject;
    //self.annotationView.translatesAutoresizingMaskIntoConstraints = YES;
    self.annotationView.delegate = self;
    [self.view addSubview:self.annotationView];
    self.annotationView.frame = CGRectMake(self.view.frame.size.width / 2 - self.annotationView.frame.size.width / 2, self.view.frame.size.height / 2 - self.annotationView.frame.size.height, self.annotationView.frame.size.width, self.annotationView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    CLLocationCoordinate2D mapCenter = mapView.centerCoordinate;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:mapCenter.latitude longitude:mapCenter.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        self.currentPlacemark = placemarks.firstObject;
        self.annotationView.labelLocation.text = self.currentPlacemark.name;
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    } else {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"pin-custom"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    @synchronized (self) {
        if (!self.mapRelocatedToUserLocation && CLLocationCoordinate2DIsValid(userLocation.coordinate) && [userLocation.location.timestamp timeIntervalSinceNow] < 400) {
            self.mapRelocatedToUserLocation = YES;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
            [self.mapViewCreateGame setRegion:region animated:YES];
        }
    }
}


#pragma mark - PUAnnotationViewDelegate methods

- (void)touchUpInsideAnnotationView:(PUAnnotationView *)view {
    
    if (self.annotationView.labelLocation.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Create game" message:@"Are you sure you want to create game at this location?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    }
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Create game"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        
        [self.hud show:YES];
        [[PUConnect sharedConnect] addParkWithName:self.currentPlacemark.name rating:5 latitude:self.currentPlacemark.location.coordinate.latitude longitude:self.currentPlacemark.location.coordinate.longitude onSuccess:^(PUPark *park) {
            [self.hud hide:NO];
            if ([self.delegate respondsToSelector:@selector(parkCreated:)]) {
                [self.delegate parkCreated:park];
            }
        } onFaliure:^(PUServerResponse serverResponseCode, NSString *message) {
            [self.hud hide:NO];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}


#pragma mark - PUHostViewControllerDelegate methods

- (void)addedEvent:(PUEvent *)event {
    
    PULobbyViewController *lobbyViewController = [[PULobbyViewController alloc] initWithNibName:@"PULobbyViewController" bundle:nil];
    lobbyViewController.event = event;
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:lobbyViewController animated:YES];
}

@end
