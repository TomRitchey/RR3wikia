//
//  TableViewController.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface TableViewController : UITableViewController

@property NSMutableArray *categories;
@property NSMutableArray *superCategories;
@property (strong, nonatomic) IBOutlet UITableView *masterTableView;

@end
