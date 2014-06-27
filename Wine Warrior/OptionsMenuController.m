//
//  OptionsMenuController.m
//  Wine Warrior
//
//  Created by Sony Theakanath on 3/22/13.
//  Copyright (c) 2013 Sony Theakanath. All rights reserved.
//

#import "OptionsMenuController.h"
#import "Appirater.h"

@interface OptionsMenuController ()

@end

static NSMutableArray* savedLinks = nil;

@implementation OptionsMenuController

@synthesize interfaceArray;

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)savenewusername{
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    [data replaceObjectAtIndex:2 withObject:usernamefield.text];
    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
    NSLog(@"%@", data);
}

-(IBAction)changeSeg{
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
	if(Segment.selectedSegmentIndex == 0){
        [data replaceObjectAtIndex:0 withObject:@"distance"];
	}
	if(Segment.selectedSegmentIndex == 1){
        [data replaceObjectAtIndex:0 withObject:@"rating"];
	}
    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
    NSLog(@"%@", data);
}

-(IBAction)changewinerysegment{
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
	if(NumberofWineriesSegment.selectedSegmentIndex == 0){
        [data replaceObjectAtIndex:1 withObject:@"5"];
	}
	if(NumberofWineriesSegment.selectedSegmentIndex == 1){
        [data replaceObjectAtIndex:1 withObject:@"10"];
	}
    if(NumberofWineriesSegment.selectedSegmentIndex == 2){
        [data replaceObjectAtIndex:1 withObject:@"15"];
	}
    if(NumberofWineriesSegment.selectedSegmentIndex == 3){
        [data replaceObjectAtIndex:1 withObject:@"20"];
	}
    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
    NSLog(@"%@", data);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath]) {
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
        usernamefield.text = [data objectAtIndex:2];
    }
    if([[data objectAtIndex:0] isEqualToString:@"distance"])
        [Segment setSelectedSegmentIndex:0];
    else
        [Segment setSelectedSegmentIndex:1];
    
    if([[data objectAtIndex:1] isEqualToString:@"5"]) {
        [NumberofWineriesSegment setSelectedSegmentIndex:0];
    } else if ([[data objectAtIndex:1] isEqualToString:@"10"]) {
        [NumberofWineriesSegment setSelectedSegmentIndex:1];
    } else if ([[data objectAtIndex:1] isEqualToString:@"15"]) {
        [NumberofWineriesSegment setSelectedSegmentIndex:2];
    } else {
        [NumberofWineriesSegment setSelectedSegmentIndex:3];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
