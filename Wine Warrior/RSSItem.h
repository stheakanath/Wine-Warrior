//
//  RSSItem.h
//  Bellarmine Political Review Mobile
//
//  Created by Sony Theakanath on May 27, 2013
//

#import <Foundation/Foundation.h>

@interface RSSItem : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) UIImage* image;

@property (strong, nonatomic) UIImage* wineryimages; //Images Uploaded

@property (strong, nonatomic) NSString* imagelink;
@property (strong, nonatomic) NSString* dateposted;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* content;
@property (strong, nonatomic) NSURL* link;
@property (strong, nonatomic) NSAttributedString* cellMessage;

//New Stuff
@property (strong, nonatomic) NSString* wineryid;
@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* phonenumber;
@property (strong, nonatomic) NSString* website;
@property (strong, nonatomic) NSString* popularity;
@property (strong, nonatomic) NSString* wineid;
@property (strong, nonatomic) NSString* wineregion;


//Detailed Wines Stuff
@property (strong, nonatomic) NSArray* wines;
@property (strong, nonatomic) NSArray* comments;
@property (strong, nonatomic) NSArray* users;

//Region Stuff
//checking if region
@property (assign) BOOL isregion;

@end