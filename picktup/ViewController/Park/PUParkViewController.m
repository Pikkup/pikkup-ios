//
//  PUParkViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUParkViewController.h"
#import "PUHostViewController.h"
#import "PULobbyViewController.h"
#import "PNTToolbar.h"

@implementation NSDate (PUDateExtensions)

- (NSComparisonResult)compareToDate:(NSDate*)date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsSelf = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDateComponents *componentsDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDate *dateSelf = [calendar dateFromComponents:componentsSelf];
    NSDate *dateDate = [calendar dateFromComponents:componentsDate];
    
    return [dateSelf compare:dateDate];
}

@end

@interface PUParkViewController () <UITableViewDataSource, UITableViewDelegate, PUHostViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewPark;
@property (weak, nonatomic) IBOutlet MKMapView *mapViewParkLocation;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *filteredEvents;

@end

@implementation PUParkViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _events = [[NSMutableArray alloc] init];
        _filteredEvents = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if (self.park) {
        self.title = self.park.title;
        
        UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithTitle:@"Create game" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAddTouchUpInside:)];
        self.navigationItem.rightBarButtonItem = barButtonItemAdd;
        
        [self.mapViewParkLocation addAnnotation:self.park];
        self.mapViewParkLocation.centerCoordinate = self.park.coordinate;
        self.mapViewParkLocation.region = MKCoordinateRegionMakeWithDistance (self.park.coordinate, 100, 1000);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    
    [self.hud show:YES];
    [[PUConnect sharedConnect] eventsForPark:self.park page:1 count:20000 onSuccess:^(NSMutableArray *events) {
        [self.hud hide:NO];
        [self.events removeAllObjects];
        [self.events addObjectsFromArray:events];
        
        [self.filteredEvents removeAllObjects];
        NSMutableArray *filteredEventsBefore = [[NSMutableArray alloc] init];
        NSMutableArray *filteredEventsToday = [[NSMutableArray alloc] init];
        NSMutableArray *filteredEventsAfter = [[NSMutableArray alloc] init];
        for (PUEvent *event in self.events) {
            NSComparisonResult result = [event.eventStartDate compareToDate:[NSDate date]];
            if (result == NSOrderedAscending) {
                [filteredEventsBefore addObject:event];
            } else if (result == NSOrderedDescending) {
                [filteredEventsAfter addObject:event];
            } else {
                [filteredEventsToday addObject:event];
            }
        }
        [self.filteredEvents addObjectsFromArray:@[filteredEventsBefore, filteredEventsToday, filteredEventsAfter]];
        [self.tableViewPark reloadData];
        
    } onFaliure:^(PUServerResponse serverResponseCode) {
        [self.hud hide:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions methods

- (void)buttonAddTouchUpInside:(id)sender {
    
    PUHostViewController *hostViewController = [[PUHostViewController alloc] initWithNibName:@"PUHostViewController" bundle:nil];
    hostViewController.delegate = self;
    hostViewController.park = self.park;
    [self.navigationController pushViewController:hostViewController animated:YES];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.filteredEvents[indexPath.section] count]) {
        static NSString *CellIdentifier = @"PUEventCell";
        PUEventCell *cell = (PUEventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil].firstObject;
        }
        PUEvent *event = self.filteredEvents[indexPath.section][indexPath.row];
        cell.event = event;
        return cell;
    } else {
        static NSString *CellIdentifier = @"PUEmptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedRegular" size:14];
        }
        cell.textLabel.text = @"There are no games";
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.filteredEvents.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.filteredEvents[section] count] + ![self.filteredEvents[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Past games";
    } else if (section == 1) {
        return @"Games today";
    } else {
        return @"Upcoming games";
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (self.filteredEvents.count > indexPath.section && [self.filteredEvents[indexPath.section] count] > indexPath.row) {
        PUEvent *event = self.filteredEvents[indexPath.section][indexPath.row];
        PULobbyViewController *lobbyViewController = [[PULobbyViewController alloc] initWithNibName:@"PULobbyViewController" bundle:nil];
        lobbyViewController.event = event;
        [self.navigationController pushViewController:lobbyViewController animated:YES];
    }
}


#pragma mark - PUHostViewControllerDelegate methods

- (void)addedEvent:(PUEvent *)event {
    
    PULobbyViewController *lobbyViewController = [[PULobbyViewController alloc] initWithNibName:@"PULobbyViewController" bundle:nil];
    lobbyViewController.event = event;
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:lobbyViewController animated:YES];
}


#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"pin-custom"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

@end
