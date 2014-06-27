//
//  ViewController.h
//  Wine Warrior
//
//  Created by Sony Theakanath on 2/17/14.
//  Copyright (c) 2014 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UITableViewController <CLLocationManagerDelegate> {
    NSMutableArray *interfaceArray;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL *ifregion;
    
}

@property (nonatomic, retain) NSMutableArray *interfaceArray;

@end
