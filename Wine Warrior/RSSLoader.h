//
//  RSSLoader.h
//  Bellarmine Political Review Mobile
//
//  Created by Sony Theakanath on May 27, 2013
//

#import <Foundation/Foundation.h>

typedef void (^RSSLoaderCompleteBlock)(NSString* title, NSArray* results);

@interface RSSLoader : NSObject

-(void)fetchRssWithURL:(NSURL*)url complete:(RSSLoaderCompleteBlock)c; //This is for the main screen
-(void)getdetailedwinery:(NSURL*)url complete:(RSSLoaderCompleteBlock)c; // THis is the deatield winery stuff


@end
