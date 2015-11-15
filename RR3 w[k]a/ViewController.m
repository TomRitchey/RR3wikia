//
//  ViewController.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    charactersExtracted = [[JsonDataExtractor alloc] initWithCategory:self.category];
    
    self.loadingThumbnailsQueue.maxConcurrentOperationCount = 30;
    self.navigationItem.title  = self.category;
    self.loadingThumbnailsQueue = [[NSOperationQueue alloc] init];

    _thumbnails = [[NSMutableArray alloc]init];
    characters = [[JsonDataGetter alloc] initWithCategory:self.category withLimit:200];
    self.tableDataFirstLetters = [[NSMutableArray alloc] init];
    
    if([self checkIfNetworkAwaliable]){
        //[self downloadAndSortData];
        [charactersExtracted preparation];
    }else{
        [self showErrorMessage];
    }
    ///////////    ///////////    ///////////    ///////////

    self.thumbnails = charactersExtracted.thumbnails;
    for (int i = 0; i < charactersExtracted.numberOfSections; i++) {
        for (int j = 0; j < [[charactersExtracted.sectionsCount objectAtIndex:i]integerValue]; j++) {
            //NSLog(@" %i %i", i , [[self.sectionsCount objectAtIndex:j]integerValue] );
            NSString *url = [[charactersExtracted.thumbnailsUrls objectAtIndex:i] objectAtIndex:j];
            
            [self downloadImage:url forIndexPath:[NSIndexPath indexPathForRow:j inSection:i] inArray:self.thumbnails];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        [self.loadingThumbnailsQueue cancelAllOperations];
        //NSLog(@"bye bye");
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   // [[self.thumbnails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
        WebViewController *controller = (WebViewController *)segue.destinationViewController;
        controller.pageTitle = [[charactersExtracted.tableData objectAtIndex:
                                [[self.subTableView indexPathForSelectedRow] section]]
    objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
    controller.url = [[charactersExtracted.urlData objectAtIndex:
                       [[self.subTableView indexPathForSelectedRow] section]]
                      objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
    //NSLog(@"url: %@",[self.urlData objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]]);
}

- (bool)checkIfNetworkAwaliable{
    bool success = NO;
    bool isAvailable = NO;
    const char *host_name = [@"http://rr3.wikia.com/wiki/Main_Page"
                             cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    return isAvailable;
}


#pragma mark table view

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
//  NSLog(@"%i",charactersExtracted.numberOfSections);
    return charactersExtracted.numberOfSections;
    //return self.numberOfSections;
}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[charactersExtracted.sectionsCount objectAtIndex:section]integerValue];
    //return [[self.sectionsCount objectAtIndex:section]integerValue];
    //return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *url = [[self.thumbnailsUrls objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    [self downloadImage:url forIndexPath:indexPath inArray:self.thumbnails];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [[charactersExtracted.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.imageView.image = [[self.thumbnails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageNamed:@"globe_icon.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    [imageView setFrame:CGRectMake(0, 0, frame.size.height*0.6, frame.size.height*0.6)];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageView setTintColor:[UIColor colorWithWhite:0.5 alpha:1]];
    cell.accessoryView = imageView;
    return cell;
}

-(UIImage *)downloadImageWithUrl:(NSString *)url{
    UIImage *tempImage;
    if(url == [NSNull null]){
        tempImage = [self genereteBlankImage];
    }else{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        tempImage = [UIImage imageWithData:imageData];
    }
    return tempImage;
}

#pragma mark tiny alphabet on the right

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [charactersExtracted.tableDataFirstLetters objectAtIndex:section];
    return [self.tableDataFirstLetters objectAtIndex:section];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    return charactersExtracted.sectionIndexTitles;
        return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark other

-(void)downloadImage:(NSString*)url forIndexPath:(NSIndexPath*)indexPath inArray:(NSMutableArray*)Array{
  
    __block NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
        if([downloadImageOperation isCancelled]){return;}
        UIImage *image = [self downloadImageWithUrl:url];
        if([downloadImageOperation isCancelled]){return;}
    if(image!=nil && ![downloadImageOperation isCancelled]){
            dispatch_async(dispatch_get_main_queue(), ^{
                if([downloadImageOperation isCancelled]){return;}
                [[Array objectAtIndex:indexPath.section]replaceObjectAtIndex:indexPath.row withObject:image];
                if([downloadImageOperation isCancelled]){return;}
                [self.subTableView reloadData];
                if ([[self.subTableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [self.subTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                             withRowAnimation:UITableViewRowAnimationFade];
                }
            });
        }
    }];
    [self.loadingThumbnailsQueue addOperation:downloadImageOperation];
}

-(UIImage *)genereteBlankImage {
    
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    
    [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark alert messages

- (void)showErrorMessage {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Connection",nil)
                                                                   message:[NSString stringWithFormat:NSLocalizedString(@"Check your internet connection or try again later.",nil)]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Dismiss",nil)]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
@end
