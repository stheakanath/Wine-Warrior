//
//  DetailViewController.m
//  Wine Warrior
//
//  Created by Sony Theakanath on May 27, 2013
//

#import "DetailViewController.h"
#import "UIImage+StackBlur.h"
#import "RSSItem.h"
#import "DYRateView.h"
#import "RXMLElement.h"
#import "NSString+URLEncoding.h"
#import <dispatch/dispatch.h>
#include <sys/socket.h>
#import "NSData+Base64.h"
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "RSSLoader.h"
#import <Social/Social.h>


@interface DetailViewController () {
    int heightsize;
    RSSItem* detailedinfo;
    RSSItem* items;
    BOOL alertisup;
    BOOL doneloadingeverything;

}
@end

@implementation DetailViewController
@synthesize touploadimage, listofwineries;

#pragma mark - Action Sheet Methods

-(IBAction)showActionSheet:(id)sender {
    if(items.isregion == FALSE) {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"More Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Navigate Here" otherButtonTitles:@"Call Winery", nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        popupQuery.tag = 0;
        [popupQuery showInView:self.view];
    } else {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"More Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Navigate Here" otherButtonTitles: nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        popupQuery.tag = 0;
        [popupQuery showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@", [items.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        } else if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", items.phonenumber]]];
        }
    } else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        } else if (buttonIndex == 1) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

#pragma mark - Image Picker Controller Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.touploadimage = info[UIImagePickerControllerEditedImage];
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Add Comment About Your Picture"];
    [dialog setMessage:@" "];
    [dialog addButtonWithTitle:@"Cancel"];
    [dialog addButtonWithTitle:@"OK"];
    dialog.tag = 10;
    dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    [dialog show];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Uploading Image Methods

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if([[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding] rangeOfString:@"http"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error!" message: @"Failed to Upload Image!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
	} else {
        imageURL = [string retain];
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:imageURL];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uploaded!" message:@"Thanks for Uploading!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Share to Facebook?", nil];
        [self startInterface];
        [alert setTag:200]; //uploading tag
        if(alertisup == false) {
            alertisup = TRUE;
            [alert show];
        }
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentNode = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if( [currentNode isEqualToString:elementName])
		currentNode = @"";
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:receivedData];
	[parser setDelegate:self];
	[parser parse];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void) uploadingFinished {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uploaded!" message:@"Thanks for Uploading!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) uploadpicture {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take Photo" otherButtonTitles:@"Select Photo From Library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    popupQuery.tag = 1;
	[popupQuery showInView:self.view];
}

#pragma mark - Table Views

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listofwineries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    RSSItem *object = self.listofwineries[indexPath.row];
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
    
    UILabel *articlename = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30, screenWidth-40 , 60)];
    [articlename setBackgroundColor:[UIColor clearColor]];
    [articlename setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40]];
    [articlename setText:object.title];
    [articlename setTextColor:[UIColor whiteColor]];
    [articlename setShadowColor:[UIColor blackColor]];
    [articlename setShadowOffset:CGSizeMake(1, 0)];
    articlename.lineBreakMode = NSLineBreakByWordWrapping;
    articlename.numberOfLines = 0;
    [cell.contentView addSubview:articlename];
    
   /* UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 74.0, screenWidth-40 , 60)];
    [date setBackgroundColor:[UIColor clearColor]];
    [date setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20]];
    [date setText:[NSString stringWithFormat:@"Region: %@", object.wineregion]];
    [date setTextColor:[UIColor whiteColor]];
    [date setShadowColor:[UIColor blackColor]];
    [date setShadowOffset:CGSizeMake(1, 0)];
    date.lineBreakMode = NSLineBreakByWordWrapping;
    date.numberOfLines = 0;
    [cell.contentView addSubview:date];*/
    
    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 47.0, screenWidth-40 , 60)];
    [author setBackgroundColor:[UIColor clearColor]];
    [author setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:22]];
   // [author setText:[NSString stringWithFormat:@"Distance: %@%@", object.author, @" miles"]];
    [author setText:[NSString stringWithFormat:@""]];
    [author setTextColor:[UIColor whiteColor]];
    [author setShadowColor:[UIColor blackColor]];
    [author setShadowOffset:CGSizeMake(1, 0)];
    author.lineBreakMode = NSLineBreakByWordWrapping;
    author.numberOfLines = 0;
    [cell.contentView addSubview:author];
    
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
    RSSItem *object = self.listofwineries[indexPath.row];
    [infoController setDetailItem:object];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:infoController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

#pragma mark - Interface Methods

- (void) startInterface {
    //Setting up background and Scroll View
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    inview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, screenWidth, screenHeight-70)];
    [inview setContentSize:CGSizeMake(screenWidth, 2000)];
    RSSItem* item = (RSSItem*)self.detailItem;
    items = item;
    self.title = item.title;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIImageView *bkgndimage =  [[UIImageView alloc] initWithImage:[item.image stackBlur:20]];
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [bkgndimage addSubview:overlay];
    bkgndimage.contentMode = UIViewContentModeScaleAspectFill;
    bkgndimage.clipsToBounds = YES;
    [bkgndimage setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self.view addSubview:bkgndimage];
    
    //WineImage
    UIImageView *wineimage =  [[UIImageView alloc] initWithImage:[item.image stackBlur:0]];
    UIView *overlay1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wineimage.frame.size.width, 80)];
    [wineimage addSubview:overlay1];
    
    wineimage.contentMode = UIViewContentModeScaleAspectFill;
    wineimage.clipsToBounds = YES;
    [wineimage setFrame:CGRectMake(0, 0, screenWidth, 215)];
    [inview addSubview:wineimage];
    
    /*Title of Winery
    CGSize sizetitle = [item.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25] constrainedToSize:CGSizeMake(screenWidth-10, 20000) lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *wineryname = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 170.0-sizetitle.height, screenWidth-10, sizetitle.height)];
    [wineryname setBackgroundColor:[UIColor clearColor]];
    [wineryname setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25]];
    [wineryname setText:item.title];
    [wineryname setTextAlignment:NSTextAlignmentLeft];
    [wineryname setTextColor:[UIColor whiteColor]];
    [wineryname setShadowColor:[UIColor blackColor]];
    [wineryname setShadowOffset:CGSizeMake(1, 0)];
    wineryname.lineBreakMode = NSLineBreakByWordWrapping;
    wineryname.numberOfLines = 0;
    [inview addSubview:wineryname];*/
    
    
    //Split
    UIView *split = [[UIView alloc] initWithFrame:CGRectMake(0, 215, screenWidth, 2)];
    UIView *topsplit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 2)];
    [split setBackgroundColor:[UIColor whiteColor]];
    [split setAlpha:1];
    [topsplit setBackgroundColor:[UIColor whiteColor]];
    [topsplit setAlpha:1];
    [inview addSubview:split];
    [inview addSubview:topsplit];
    
    //Rating and Distance from Location
    NSString *ratinganddistancetext;
    if(item.isregion == FALSE) {
        ratinganddistancetext = [NSString stringWithFormat:@"Avg Rating: %@", item.dateposted];
    } else {
        ratinganddistancetext = [NSString stringWithFormat:@"Main Town: %@", item.wineregion];
    }
    CGSize sizeRatingdistance = [ratinganddistancetext sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15] constrainedToSize:CGSizeMake(screenWidth-10, 20000) lineBreakMode:UILineBreakModeTailTruncation];
    UILabel *ratinganddistance = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 255, screenWidth-10, sizeRatingdistance.height)];
    [ratinganddistance setBackgroundColor:[UIColor clearColor]];
    [ratinganddistance setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
    [ratinganddistance setText:ratinganddistancetext];
    [ratinganddistance setTextAlignment:NSTextAlignmentLeft];
    [ratinganddistance setTextColor:[UIColor whiteColor]];
    [ratinganddistance setShadowColor:[UIColor blackColor]];
    [ratinganddistance setShadowOffset:CGSizeMake(1, 0)];
    ratinganddistance.lineBreakMode = NSLineBreakByWordWrapping;
    ratinganddistance.numberOfLines = 0;
    [inview addSubview:ratinganddistance];
    [[self view] addSubview:inview];
    
    //Overview stuff
    CGSize overviewtitlesize = [item.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25] constrainedToSize:CGSizeMake(screenWidth-10, 20000) lineBreakMode:UILineBreakModeTailTruncation];
    UILabel *overviewtitle = [self makeLabel];
    overviewtitle.text = item.title;
    [overviewtitle setFrame:CGRectMake(10.0, 220, screenWidth-10, overviewtitlesize.height)];
    [inview addSubview:overviewtitle];
    NSString *dummytext = item.content;
    CGSize overviewcontentsize = [dummytext sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15] constrainedToSize:CGSizeMake(screenWidth-10, 20000) lineBreakMode:UILineBreakModeTailTruncation];
    UILabel *overviewcontent = [self makeLabel];
    overviewcontent.text = dummytext;
    overviewcontent.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    [overviewcontent setFrame:CGRectMake(10.0, 280, screenWidth-10, overviewcontentsize.height)];
    [inview addSubview:overviewcontent];
    
    if(items.isregion == TRUE) {
        UIView *split2 = [[UIView alloc] initWithFrame:CGRectMake(0, overviewcontentsize.height+288, screenWidth, 2)];
        [split2 setBackgroundColor:[UIColor whiteColor]];
        [inview addSubview:split2];
        RSSLoader* rss = [[RSSLoader alloc] init];
        //ACTUAL LINK
        NSString *u  = [NSString stringWithFormat:@"http://www.puzha.com/ww/api/get-wineries.php?id=%@&wineries_count=5",item.wineryid];
        NSLog(@"%@", u);
     //   NSString *u  = [NSString stringWithFormat:@"http://www.puzha.com/ww/api/startup.php?id=%@&wineries_count=5",item.wineryid];
        NSURL *theurl = [NSURL URLWithString:u];
        [rss fetchRssWithURL:theurl complete:^(NSString *title, NSArray *results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *test = [[NSMutableArray alloc] init];
                [test addObjectsFromArray:self.listofwineries];
                if([results count] == 0) {
                    doneloadingeverything = true;
                    NSArray *viewsToRemove = [winerysinregiontableview.tableFooterView subviews];
                    for (UIView *v in viewsToRemove) {
                        [v removeFromSuperview];
                    }
                    winerysinregiontableview.tableFooterView.hidden = NO;
                    winerysinregiontableview.contentInset = UIEdgeInsetsMake(0, 0, -50, 0);
                }
                [test addObjectsFromArray:results];
                self.listofwineries = [NSArray arrayWithArray:test];
                if([self.listofwineries count] > 0) {
                    winerysinregiontableview = [[UITableView alloc] initWithFrame:CGRectMake(0, overviewcontentsize.height+290, screenWidth, [self.listofwineries count]*125)];
                    winerysinregiontableview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                    winerysinregiontableview.delegate = self;
                    winerysinregiontableview.dataSource = self;
                    winerysinregiontableview.scrollEnabled = NO;
                    [inview addSubview:winerysinregiontableview];
                    [winerysinregiontableview reloadData];
                    winerysinregiontableview.tableFooterView.hidden = YES;
                    [inview setContentSize:CGSizeMake(screenWidth, [self.listofwineries count]*125+overviewcontentsize.height+290)];
                }
            });}];
    } else {

        //Comments
        UILabel *ratings = [self makeLabel];
        ratings.text= @"Comments";
        [ratings setFrame:CGRectMake(10.0, overviewcontentsize.height+overviewtitlesize.height+195+sizeRatingdistance.height+40, screenWidth-10, 30)];
        [inview addSubview:ratings];
        heightsize = overviewcontentsize.height+overviewtitlesize.height+195+sizeRatingdistance.height+40+30;
        
        //Getting Detailed Winery Material
        NSString *url = [NSString stringWithFormat:@"http://www.puzha.com/ww/api/get-winery-detail.php?id=%@&comment_count=3&comment_sort=latest", item.wineryid];
        NSURL *detailedurl = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        RXMLElement *rss1 = [RXMLElement elementFromURL: detailedurl];
        detailedinfo = [[RSSItem alloc] init];
        NSArray *commentuphold = [[rss1 child:@"comments"] children:@"comment"];
        NSMutableArray *comments = [[NSMutableArray alloc] initWithObjects:nil];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for(int x = 0; x < [commentuphold count]; x++) {
            [comments addObject:[[commentuphold objectAtIndex:x] child:@"text"]];
            NSString *userstring = [NSString stringWithFormat:@"%@ at %@", [[commentuphold objectAtIndex:x] child:@"user_name"],[[commentuphold objectAtIndex:x] child:@"time"]];
            [users addObject:userstring];
        }
        detailedinfo.comments = [NSArray arrayWithArray:comments];
        detailedinfo.users = [NSArray arrayWithArray:users];
        
        NSMutableArray *wines = [[NSMutableArray alloc] init];
        NSMutableArray *linkstowines = [[NSMutableArray alloc] init];
        NSArray *wineuphoad = [[rss1 child:@"wines"] children:@"wine"];
        for(int x = 0; x < [wineuphoad count]; x++) {
            [wines addObject:[[wineuphoad objectAtIndex:x] child:@"short_desc"]];
            [linkstowines addObject:[[wineuphoad objectAtIndex:x] child:@"link"]];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        heightsize -= 20;
        for(int x = 0; x < [comments count]; x++) {
            UILabel *username = [self makeLabel];
            username.text = [users objectAtIndex:x];
            username.textAlignment = NSTextAlignmentLeft;
            username.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15];
            [username setFrame:CGRectMake(40.0, heightsize+20, screenWidth-50, 30)];
            heightsize += 50;
            [inview addSubview:username];
            
            UILabel *review = [self makeLabel];
            CGSize commentsize = [[NSString stringWithFormat:@"%@",[comments objectAtIndex:x]] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15] constrainedToSize:CGSizeMake(screenWidth-50, 20000) lineBreakMode:UILineBreakModeTailTruncation];
            review.text = [NSString stringWithFormat:@"%@",[comments objectAtIndex:x]];
            review.textAlignment = NSTextAlignmentLeft;
            review.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
            [review setFrame:CGRectMake(40.0, heightsize, screenWidth-50, commentsize.height)];
            heightsize += commentsize.height;
            [inview addSubview:review];
        }
        
        UIView *split2 = [[UIView alloc] initWithFrame:CGRectMake(10, heightsize+20, screenWidth-20, 2)];
        [split2 setBackgroundColor:[UIColor whiteColor]];
        [split2 setAlpha:0.6];
        [inview addSubview:split2];
        heightsize += 20;
        
        //Buttons to Add rating, Upload Pictures and Add Comment
        DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, heightsize+20, self.view.bounds.size.width, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
        rateView.padding = 20;
        rateView.alignment = RateViewAlignmentCenter;
        rateView.editable = YES;
        rateView.delegate = self;
        [inview addSubview:rateView];
        UILabel *rateme = [self makeLabel];
        rateme.text = @"Rate This Winery!";
        rateme.textAlignment = NSTextAlignmentCenter;
        rateme.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15];
        [rateme setFrame:CGRectMake(0.0, heightsize+40, screenWidth, 30)];
        heightsize += 50;
        [inview addSubview:rateme];
        
        UIButton *addcomment = [self makebutton];
        UIButton *uploadpicture = [self makebutton];
        [addcomment setFrame:CGRectMake(screenWidth/2-145, heightsize+40, 140, 35)];
        [addcomment setTitle:@"Add Comment" forState:UIControlStateNormal];
        [addcomment addTarget:self action:@selector(uploadcomment) forControlEvents:UIControlEventTouchUpInside];
        [uploadpicture setFrame:CGRectMake(screenWidth/2+5, heightsize+40, 140, 35)];
        [uploadpicture setTitle:@"Add Picture" forState:UIControlStateNormal];
        [uploadpicture addTarget:self action:@selector(uploadpicture) forControlEvents:UIControlEventTouchUpInside];
        [inview addSubview:addcomment];
        [inview addSubview:uploadpicture];
        heightsize+=70;
        [inview setContentSize:CGSizeMake(screenWidth, heightsize+20)];
    }
}

- (UILabel *)makeLabel{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 0);
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)makebutton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button  setBackgroundImage:[UIImage imageNamed:@"PredictButton.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"PredictButton_Selected.png"] forState:UIControlStateHighlighted];
    return button;
}

-(void)viewDidLoad {
    [self startInterface];
}

#pragma mark - Comment and Rate Methods

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.puzha.com/ww/api/save-winery-rating.php?id=%@&mac_adrs=%@&rating=%@", items.wineryid, [self getMacAddress], rate]];
    NSString *blork = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:url] encoding: NSASCIIStringEncoding];
    if ([blork rangeOfString:@"OK"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Rated!" message:@"We got an error! This winery has not been rated." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rated!" message:@"Thanks for rating this winery!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) uploadcomment {
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Add Comment About the Winery"];
    [dialog setMessage:@" "];
    [dialog addButtonWithTitle:@"Cancel"];
    [dialog addButtonWithTitle:@"Send"];
    dialog.tag = 5;
    dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    [dialog show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 5) {
        alertisup = false;

        if (buttonIndex != 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
            NSMutableArray *data = [[NSMutableArray alloc] init];
            if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
                data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
            
            NSString *uploadCall = [NSString stringWithFormat:@"obj_type=winery&id=%@&comment=%@&mac_adrs=%@&username=%@",items.wineryid,[[alertView textFieldAtIndex: 0] text], [self getMacAddress], [self getusername]];
            NSLog(@"%@", uploadCall);
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.puzha.com/ww/api/save-comment.php"]];
			[request setHTTPMethod:@"POST"];
			[request setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
			[request setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLResponse *response;
            NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
            NSString *blork = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
            if ([blork rangeOfString:@"OK"].location == NSNotFound) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Commented!" message:@"We got an error! Comment has not been added to the winery." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                [self startInterface];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commented!" message:@"Thanks for commenting on this winery!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    } else if ([alertView tag] == 10) {
        alertisup = false;

        if (buttonIndex != 0) {
            dispatch_queue_t queue = dispatch_queue_create("com.Blocks.task",NULL);
            dispatch_queue_t main = dispatch_get_main_queue();
            dispatch_async(queue,^{
                NSData *imageData  = UIImageJPEGRepresentation(self.touploadimage, 0.3); // High compression due to 3G.
                NSString *imageB64   = [imageData base64EncodingWithLineLength:0];
                imageB64 = [imageB64 encodedURLString];
                dispatch_async(main,^{
                    NSString *uploadCall = [NSString stringWithFormat:@"mac_adrs=%@&object_type=winery&id=%@&username=%@&img_str=%@&img_caption=%@",[self getMacAddress], items.wineryid, [self getusername], imageB64, [[alertView textFieldAtIndex: 0] text]];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.puzha.com/ww/api/save-image.php"]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
                    [request setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding]];
                    NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
                    if (theConnection)  {
                        receivedData=[[NSMutableData data] retain];
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    } else {
                    }
                });
            });
        }
    } else if ([alertView tag] == 200) {
        alertisup = false;
        if(buttonIndex != 0) {
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [controller setInitialText:@"Posted from WineWarrior. http://puzha.com/winewarrior/"];
                [controller addImage:self.touploadimage];
                [self presentViewController:controller animated:YES completion:Nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Facebook Linked" message: @"Go to Settings > Facebook to add your Facebook account." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

#pragma mark - Other Retriever Methods

- (NSString *)getMacAddress {
    int  mgmtInfoBase[6];
    char *msgBuffer = NULL;
    NSString *errorFlag = NULL;
    size_t length;
    mgmtInfoBase[0] = CTL_NET;
    mgmtInfoBase[1] = AF_ROUTE;
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;
    mgmtInfoBase[4] = NET_RT_IFLIST;
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    } else {
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        free(msgBuffer);
        return macAddressString;
    }
    NSLog(@"Error: %@", errorFlag);
    return nil;
}

- (NSString*) getusername {
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    return [data objectAtIndex:2];
}

@end