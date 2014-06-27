//
//  RSSLoader.m
//  Bellarmine Political Review Mobile
//
//  Created by Sony Theakanath on May 27, 2013
//

#import "RSSLoader.h"
#import "RXMLElement.h"
#import "GTMNSString+HTML.h"
#import "NSString+HTML.h"
#import "RSSItem.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation RSSLoader

-(void)fetchRssWithURL:(NSURL*)url complete:(RSSLoaderCompleteBlock)c {
    dispatch_async(kBgQueue, ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        RXMLElement *rss = [RXMLElement elementFromURL: url];
        RXMLElement* title;
        NSMutableArray* result;
        if(![rss.text length] == 0) {
            title = [[rss child:@"channel"] child:@"title"];
            if([[rss children:@"winery"] count] == 0) {
                NSArray* items = [rss children:@"region"];
                result = [NSMutableArray arrayWithCapacity:items.count];
                for (RXMLElement *e in items) {
                    RSSItem* item = [[RSSItem alloc] init];
                    
                    //Title
                    item.title = [[e child:@"name"] text];
                    
                    //Featured Image
                    NSString *image = [[e child:@"image"] text];
                    item.imagelink = image;
                    NSURL *imageURL = [NSURL URLWithString:image];
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    item.image =  [UIImage imageWithData:imageData];
                    
                    //Featured Image
                    NSString *image1 = [[e child:@"img"] text];
                    NSURL *imageURL1 = [NSURL URLWithString:image1];
                    NSData *imageData1 = [NSData dataWithContentsOfURL:imageURL1];
                    item.wineryimages =  [UIImage imageWithData:imageData1];
                    
                    //Region
                    item.wineregion = [[[e child: @"location"] child:@"main_town_name"]text];
                    
                    //Rating
                    
                    item.dateposted = [[[e child: @"location"] child:@"main_town_zip"] text];
                    
                    item.address = [[[e child: @"location"] child:@"main_town_zip"] text];
                    
                    //Winery ID
                    item.wineryid = [[e child:@"id"] text];
                    
                    //Description of Winery
                    item.content = [[e child:@"description"] text];
                    item.isregion = TRUE;
                    [result addObject: item];
                }
            } else {
                NSArray* items = [rss children:@"winery"];
                result = [NSMutableArray arrayWithCapacity:items.count];
                for (RXMLElement *e in items) {
                    RSSItem* item = [[RSSItem alloc] init];
                    
                    //Title
                    item.title = [[e child:@"name"] text];
                    
                    //Featured Image
                    NSString *image = [[e child:@"image"] text];
                    item.imagelink = image;
                    NSURL *imageURL = [NSURL URLWithString:image];
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    item.image =  [UIImage imageWithData:imageData];
                    
                    //Region
                    item.wineregion = [[e child: @"wine_region_name"] text];
                    
                    //Rating

                    item.dateposted = [[e child:@"rating"] text];
                    
                    //Distance
                    item.author = [[e child:@"distance"] text];

                    //Winery ID
                    item.wineryid = [[e child:@"id"] text];
                    
                    //Address
                    item.address = [[e child:@"address"] text];
                
                    //Phone
                    item.phonenumber = [[e child:@"phone"] text];
                    //Popularity
                    item.category = [[e child:@"popularity"] text];
                    
                    //Link
                    item.link = [NSURL URLWithString: [[e child:@"link"] text]];
                    
                    //Description of Winery
                    item.content = [[e child:@"description"] text];
                    item.isregion = FALSE;
                    [result addObject: item];
                }
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            result = [NSMutableArray array];
        }
        c([title text], result);
    });

}

-(NSMutableArray*)fetch:(NSURL*)url {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    RXMLElement *rss = [RXMLElement elementFromURL: url];
    NSMutableArray* result;

    NSArray* items = [rss children:@"winery"];
    result = [NSMutableArray arrayWithCapacity:items.count];
    for (RXMLElement *e in items) {
        RSSItem* item = [[RSSItem alloc] init];
        
        //Title
        item.title = [[e child:@"name"] text];
        
        //Featured Image
        NSString *image = [[e child:@"image"] text];
        item.imagelink = image;
        NSURL *imageURL = [NSURL URLWithString:image];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        item.image =  [UIImage imageWithData:imageData];
        
        //Region
        item.wineregion = [[e child: @"wine_region_name"] text];
        
        //Rating
        
        item.dateposted = [[e child:@"rating"] text];
        
        //Distance
        item.author = [[e child:@"distance"] text];
        
        //Winery ID
        item.wineryid = [[e child:@"id"] text];
        
        //Address
        item.address = [[e child:@"address"] text];
        
        //Phone
        item.phonenumber = [[e child:@"phone"] text];
        //Popularity
        item.category = [[e child:@"popularity"] text];
        
        //Link
        item.link = [NSURL URLWithString: [[e child:@"link"] text]];
        
        //Description of Winery
        item.content = [[e child:@"description"] text];
        item.isregion = FALSE;
        [result addObject: item];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    return result;
}

-(void)getdetailedwinery:(NSURL*)url complete:(RSSLoaderCompleteBlock)c {
    dispatch_async(kBgQueue, ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        RXMLElement *rss = [RXMLElement elementFromURL: url];
        RXMLElement* title;
        RSSItem* item = [[RSSItem alloc] init];
        NSArray *commentuphold = [[rss child:@"comments"] children:@"comment"];
        NSMutableArray *comments = [[NSMutableArray alloc] initWithObjects:nil];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for(int x = 0; x < [commentuphold count]; x++) {
            [comments addObject:[[commentuphold objectAtIndex:x] child:@"text"]];
            NSString *userstring = [NSString stringWithFormat:@"%@ at %@", [[commentuphold objectAtIndex:x] child:@"user_name"],[[commentuphold objectAtIndex:x] child:@"time"]];
            [users addObject:userstring];
        }
        item.comments = [NSArray arrayWithArray:comments];
        item.users = [NSArray arrayWithArray:users];
        
        NSMutableArray* result = [[NSMutableArray alloc] init];
        [result addObject: item];
        RSSItem *test = [result
                         objectAtIndex:0];
        
        NSLog(@"%@", test.comments);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        c([title text], result);
    });
    
}

-(NSString *) strip:(NSString*)url {
    NSRange r;
    NSString *s = [url copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
