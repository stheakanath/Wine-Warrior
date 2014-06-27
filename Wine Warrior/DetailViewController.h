//
//  DetailViewController.h
//  Wine Warrior
//
//  Created by Sony Theakanath on May 27, 2013
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface DetailViewController : UIViewController<DYRateViewDelegate, UIActionSheetDelegate,UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSXMLParserDelegate,UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *interfaceArray;
    UIScrollView *inview;
    NSMutableData *receivedData;
	NSString* imageURL;
	NSString* currentNode;
    UITableView *winerysinregiontableview;
    UIImage *touploadimage;
    NSArray *listofwineries;
}

@property (strong, nonatomic) id detailItem;
@property(nonatomic, strong)NSArray *listofwineries;
@property(nonatomic, strong)UIImage *touploadimage;
-(IBAction)showActionSheet:(id)sender;



@end
