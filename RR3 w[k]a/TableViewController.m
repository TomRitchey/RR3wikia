//
//  TableViewController.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()


@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.superCategories = [[NSMutableArray alloc] init];
    [self.superCategories addObjectsFromArray:[ NSArray arrayWithObjects:@"Manufacturers",@"Racing series",  nil]];
    
    self.categories = [[NSMutableArray alloc] init];
    self.noobCategories = [[NSMutableArray alloc] init];
    
    NSMutableArray *memory = [[NSUserDefaults standardUserDefaults] objectForKey:HSMEMORY];
    
    [self.categories addObjectsFromArray:self.superCategories];
    //NSLog(@"%@",self.superCategories);
    [self.noobCategories addObjectsFromArray:memory];
    //NSLog(@"%@ memory",memory);
    [self.categories addObjectsFromArray:self.noobCategories];
    //NSLog(@"%@",self.categories);
    
    
    
    //[self addObserver:self forKeyPath:@"self.categories" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
            ViewController *controller = (ViewController *)segue.destinationViewController;
            controller.category = [self.categories objectAtIndex:[[self.masterTableView indexPathForSelectedRow] row]];
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //NSLog(@"observer");
//    if ([keyPath isEqualToString:@"self.categories"]) {
//        self.noobCategories = self.categories;
//        [self.noobCategories removeObjectsInRange:NSMakeRange(0,self.superCategories.count-1)];
//            [[NSUserDefaults standardUserDefaults] setObject:self.noobCategories forKey:HSMEMORY];
//
//    }
    
//}

- (IBAction)addButtonPressed:(id)sender {
    
    bool editionIsAllowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_adding_list"];
    
    if (!editionIsAllowed) {[self showErrorMessageWithTitle:[NSString stringWithFormat:@"Adding is disabled"] andMessage:[NSString stringWithFormat:@"You can turn on editing in Settings"] goToSettings:YES];
        [self.masterTableView reloadData];
        return;}
    
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Add new category"
                                          message:@"Type your new category"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"newCategoryPlaceholder";
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                      
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *newCategory = alertController.textFields.firstObject;
                                   [self addCategory:newCategory.text];
                                   //[self.categories addObject:newCategory.text];
                                   [self.masterTableView reloadData];
                               }];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return ([self.categories count]);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *mainTableIdentifier = @"MasterTableItem";
    static NSString *addTableIdentifier = @"ManufacturerTableItem";

    //UITableViewCell *cell = [[UITableViewCell alloc]init];
    
//    if([[self.categories objectAtIndex: indexPath.row ] isEqualToString:[NSString stringWithFormat:@"Manufacturers"]]){
    if(indexPath.row < [self.superCategories count]){
        UITableViewCell *cell = [self.masterTableView dequeueReusableCellWithIdentifier:addTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addTableIdentifier];
        }
        
        cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Shows list of subcategories instead of articles"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
    
    
    UITableViewCell *cell = [self.masterTableView dequeueReusableCellWithIdentifier:mainTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mainTableIdentifier];
    }
    
        cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.superCategories.count) {
        return NO;
    }
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    bool editionIsAllowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled_deleting_list"];
    
    if (!editionIsAllowed) {[self showErrorMessageWithTitle:[NSString stringWithFormat:@"Deleting is disabled"] andMessage:[NSString stringWithFormat:@"You can turn on editing in Settings"] goToSettings:YES];
        [self.masterTableView reloadData];
        return;}
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self removeCategory:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)removeCategory:(NSIndexPath*)indexPath{
    [self.categories removeObjectAtIndex:indexPath.row];
    [self.noobCategories removeObjectAtIndex:(indexPath.row - self.superCategories.count)];
    [[NSUserDefaults standardUserDefaults] setObject:self.noobCategories forKey:HSMEMORY];
}

-(void)addCategory:(NSString*)string{
    
    [self.categories addObject:string];
    [self.noobCategories addObject:string];
    [[NSUserDefaults standardUserDefaults] setObject:self.noobCategories forKey:HSMEMORY];
}




#pragma mark error message

- (void)showErrorMessageWithTitle:(NSString*)messageTitle andMessage:(NSString*)message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",messageTitle]                                                                   message:[NSString stringWithFormat:@"%@",message]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Dismiss",nil)]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

- (void)showErrorMessageWithTitle:(NSString*)messageTitle andMessage:(NSString*)message goToSettings:(bool)goToSettings{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",messageTitle]                                                                   message:[NSString stringWithFormat:@"%@",message]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Dismiss",nil)]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    if (goToSettings) {
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Settings",nil)]
                                                            style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                           }];
    
        [alert addAction:settingsAction];
    }
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
//    
//    if(translation.y > 0)
//    {
//        NSLog(@"Drag down");
//    } else
//    {
//        NSLog(@"Drag up");
//    }
//}




/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
