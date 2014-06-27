//
//  ViewController.m
//  Wine Warrior
//
//  Created by Sony Theakanath on 2/17/14.
//  Copyright (c) 2014 Sony Theakanath. All rights reserved.
//

#import "RSSLoader.h"
#import "RSSItem.h"
#import "ViewController.h"
#import "DetailViewController.h"
#import "OptionsMenuController.h"

@interface ViewController () {
    NSArray *_objects;
    NSURL* feedURL;
    CLLocation *currentlocation;
    BOOL doneloadingeverything;
    BOOL called;
}

@end

@implementation ViewController
@synthesize interfaceArray;


-(void) startInterface {
    //Editing Navigation Controller
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Wine Warrior"];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0]];
    [shadow setShadowOffset: CGSizeMake(0.0f, -1.0f)];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSShadowAttributeName:shadow, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0] };
    self.navigationItem.title = @"Wine Warrior";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:132/255.0f green:1/255.0f blue:180/255.0f alpha:1.0f];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *settingsbutton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStyleBordered target:self action:@selector(opensettings)];
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, NSFontAttributeName, nil];
    [settingsbutton setTitleTextAttributes:dict forState:UIControlStateNormal];
    [settingsbutton setTintColor:[UIColor whiteColor]];
    //[titleItem setRightBarButtonItem:settingsbutton];
    self.navigationItem.rightBarButtonItem = settingsbutton;
    UIBarButtonItem *reloadbutton = [[UIBarButtonItem alloc] initWithTitle:@"\u21BB" style:UIBarButtonItemStyleBordered target:self action:@selector(reloadwines)];
    UIFont *f2 = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:f2, NSFontAttributeName, nil];
    [reloadbutton setTitleTextAttributes:dict2 forState:UIControlStateNormal];
    [reloadbutton setTintColor:[UIColor whiteColor]];
    //[titleItem setLeftBarButtonItem:reloadbutton];
}

-(void)refreshFeed:(NSURL*)theurl {
    RSSLoader* rss = [[RSSLoader alloc] init];
    [rss fetchRssWithURL:theurl complete:^(NSString *title, NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *test = [[NSMutableArray alloc] init];
            [test addObjectsFromArray:_objects];
            if([results count] == 0) {

                doneloadingeverything = true;
                NSArray *viewsToRemove = [self.tableView.tableFooterView subviews];
                for (UIView *v in viewsToRemove) {
                    [v removeFromSuperview];
                }
                self.tableView.tableFooterView.hidden = NO;
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -50, 0);
            }
            [test addObjectsFromArray:results];
            _objects = [NSArray arrayWithArray:test];
            [self.tableView reloadData];
            self.tableView.tableFooterView.hidden = YES;
        });}];
}

-(void) reloadwines {
    [self refreshFeed:feedURL];
}

- (void) opensettings {
    OptionsMenuController *ainfoController = [[OptionsMenuController alloc] initWithNibName:@"OptionsMenuController" bundle:nil];
    ainfoController.modalTransitionStyle = UIViewAnimationOptionTransitionFlipFromBottom;
    [self presentViewController:ainfoController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startInterface];
	// Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    [self getCurrentLocation];
    doneloadingeverything = false;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table Views

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    RSSItem *object = _objects[indexPath.row];
    static NSString *MyIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    } else {
        for (UIView *subview in cell.contentView.subviews)
            [subview removeFromSuperview];
    }
    UIImageView *bkgndimage =  [[UIImageView alloc] initWithImage:object.image];
    bkgndimage.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundView = bkgndimage;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundView.clipsToBounds = YES;
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, bkgndimage.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [bkgndimage addSubview:overlay];
    if(object.isregion == FALSE) {
        UILabel *articlename = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, screenWidth-40 , 60)];
        [articlename setBackgroundColor:[UIColor clearColor]];
        [articlename setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40]];
        [articlename setText:object.title];
        [articlename setTextColor:[UIColor whiteColor]];
        [articlename setShadowColor:[UIColor blackColor]];
        [articlename setShadowOffset:CGSizeMake(1, 0)];
        articlename.lineBreakMode = NSLineBreakByWordWrapping;
        articlename.numberOfLines = 0;
        [cell.contentView addSubview:articlename];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 74.0, screenWidth-40 , 60)];
        [date setBackgroundColor:[UIColor clearColor]];
        [date setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20]];
        if(object.isregion == TRUE) {
            [date setText:[NSString stringWithFormat:@"Main Zip Code: %@", object.dateposted]];
        } else {
           // [date setText:[NSString stringWithFormat:@"Avg. Rating: %@", object.dateposted]];
           // [date setText:[NSString stringWithFormat:@"Phone Number: %@", object.phonenumber]];
        }
        [date setTextColor:[UIColor whiteColor]];
        [date setShadowColor:[UIColor blackColor]];
        [date setShadowOffset:CGSizeMake(1, 0)];
        date.lineBreakMode = NSLineBreakByWordWrapping;
        date.numberOfLines = 0;
        [cell.contentView addSubview:date];
        
        UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 47.0, screenWidth-40 , 60)];
        [author setBackgroundColor:[UIColor clearColor]];
        [author setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:22]];
        if(object.isregion == TRUE) {
            [author setText:[NSString stringWithFormat:@"Main Town: %@", object.wineregion]];
        } else {
           // [author setText:[NSString stringWithFormat:@"Avg. Rating: %@", object.dateposted]];
           [author setText:[NSString stringWithFormat:@"Rating: %@", object.dateposted]];
        }
        [author setTextColor:[UIColor whiteColor]];
        [author setShadowColor:[UIColor blackColor]];
        [author setShadowOffset:CGSizeMake(1, 0)];
        author.lineBreakMode = NSLineBreakByWordWrapping;
        author.numberOfLines = 0;
        [cell.contentView addSubview:author];
    } else {
        UILabel *articlename = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30.0, screenWidth-40 , 60)];
        [articlename setBackgroundColor:[UIColor clearColor]];
        [articlename setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40]];
        [articlename setText:object.title];
        [articlename setTextColor:[UIColor whiteColor]];
        [articlename setShadowColor:[UIColor blackColor]];
        [articlename setShadowOffset:CGSizeMake(1, 0)];
        articlename.lineBreakMode = NSLineBreakByWordWrapping;
        articlename.numberOfLines = 1;
        articlename.minimumFontSize = 0;
        articlename.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:articlename];
    }
    
    UIView *category = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 125)];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:object.dateposted];
    double ratingnum = [myNumber doubleValue];
    if(ratingnum < 4 && ratingnum > 2.5)
        category.backgroundColor = [UIColor colorWithRed:0 green:0.47 blue:0.725 alpha:1.0];
    else if(ratingnum <= 2.5)
        category.backgroundColor = [UIColor colorWithRed:0.752 green:0.12 blue:0.15 alpha:1.0];
    else
        category.backgroundColor = [UIColor colorWithRed:0.254 green:0.678 blue:0.286 alpha:1.0];
    [cell.contentView addSubview:category];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController* infoController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    RSSItem *object = _objects[indexPath.row];
    [infoController setDetailItem:object];
    [self.navigationController pushViewController:infoController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentlocation = newLocation;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RETRIEVED LOCATION" message:[NSString stringWithFormat:@"%@", newLocation] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert setTag:12];
    [alert show];
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    else {
        [data insertObject:@"distance" atIndex:0];
        [data insertObject:@"5" atIndex:1];
        [data insertObject:@"Anonymous" atIndex:2];
    }
    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
    //ACTUAL LINK
    if(called != TRUE) {
     // NSString *urlstring  = [NSString stringWithFormat:@"http://www.puzha.com/ww/api/get-regions.php?geoloc=%f%@%f&sortplan=%@&lang=en&count=%@",currentlocation.coordinate.latitude, @",", currentlocation.coordinate.longitude, [data objectAtIndex:0], [data objectAtIndex:1]];
    NSString *urlstring  = [NSString stringWithFormat:@"http://www.puzha.com/ww/api/startup.php?geoloc=%f%@%f&sortplan=%@&lang=en&count=%@",currentlocation.coordinate.latitude, @",", currentlocation.coordinate.longitude, [data objectAtIndex:0], [data objectAtIndex:1]];
        
    //    NSString *urlstring  = [NSString stringWithFormat:@"http://www.puzha.com/ww/api/get-wineries.php?zip=95128"];
        NSLog(@"%@", urlstring);
        feedURL = [NSURL URLWithString:urlstring];
        [self refreshFeed:feedURL];
    }
    called = TRUE;
    [locationManager stopUpdatingLocation];
}

- (void)getCurrentLocation {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    __block BOOL finished = NO;
    [geocoder reverseGeocodeLocation: locationManager.location completionHandler: ^(NSArray *placemarks, NSError *error) {
        finished = YES;
        if(finished == YES) {
            if([CLLocationManager authorizationStatus]) {
                
            } else {
                if(![CLLocationManager authorizationStatus]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service for this app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert setTag:12];
                    [alert show];
                }
            }
        }
    }];
}


@end
