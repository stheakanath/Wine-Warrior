//
//  OptionsMenuController.h
//  Wine Warrior
//
//  Created by Sony Theakanath on 3/22/13.
//  Copyright (c) 2013 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsMenuController : UIViewController {
    NSArray *interfaceArray;
    IBOutlet UISegmentedControl *Segment;
    IBOutlet UITextField *usernamefield;
    IBOutlet UISegmentedControl *NumberofWineriesSegment;
}

@property (nonatomic, retain) NSArray *interfaceArray;
-(IBAction)changeSeg;
-(IBAction)changewinerysegment;
-(IBAction)savenewusername;

@end
