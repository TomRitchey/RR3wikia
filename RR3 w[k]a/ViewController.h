//
//  ViewController.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "JsonDataGetter.h"
#import "WebViewController.h"

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    JsonDataGetter *characters;
}
@property NSMutableArray *thumbnailsUrls;
@property NSMutableArray *thumbnails;
@property NSMutableArray *tableData;
@property NSMutableArray *tableDataFirstLetters;

@property NSMutableArray *urlData;
@property NSOperationQueue *loadingThumbnailsQueue;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (strong, nonatomic) IBOutlet UITableView *subTableView;
@property NSString *category;
@property NSInteger numberOfSections;
@property NSMutableArray *sectionsCount;

@end

