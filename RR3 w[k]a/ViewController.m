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
    
    self.loadingThumbnailsQueue.maxConcurrentOperationCount = 30;
    self.navigationItem.title  = self.category;
    self.category = [self replaceCharacters:self.category];
    self.loadingThumbnailsQueue = [[NSOperationQueue alloc] init];

    _thumbnails = [[NSMutableArray alloc]init];
    characters = [[JsonDataGetter alloc] initWithCategory:self.category withLimit:200];
    self.tableDataFirstLetters = [[NSMutableArray alloc] init];
    
    if([self checkIfNetworkAwaliable]){
        [self downloadAndSortData];
    }else{
        [self showErrorMessage];
    }
    ///////////    ///////////    ///////////    ///////////
    
    NSString *currentPrefix;
    NSMutableArray* sortedData = [[NSMutableArray alloc] init];
    NSMutableArray* sortedThumbnails = [[NSMutableArray alloc] init];
    NSMutableArray* sortedUrls = [[NSMutableArray alloc] init];
    NSMutableArray* sortedThumbnailsUrls = [[NSMutableArray alloc] init];
    
    NSMutableArray* firstLetters = [[NSMutableArray alloc] init];
    
    bool firstTime = YES;
    for (int i=0;i<self.tableData.count;i++){
        NSString *firstLetter = [[self.tableData objectAtIndex:i]substringToIndex:1];
       
        if([[self.tableData objectAtIndex:i] containsString:self.category]){
            //NSLog(@"%@  category %@",[self.tableData objectAtIndex:i], self.category);
            if(firstTime){
                [firstLetters insertObject:self.category atIndex:0];
                //[firstLetters insertObject:[NSString stringWithFormat:@"★"] atIndex:0];
//                NSMutableArray *newArray = [[NSMutableArray alloc] init];
                NSMutableArray *newArray = [[NSMutableArray alloc] initWithObjects:[self.tableData objectAtIndex:i], nil];
                [sortedData insertObject:newArray atIndex:0];
                NSMutableArray *newArray1 = [[NSMutableArray alloc] initWithObjects:[self.thumbnails objectAtIndex:i], nil];
                [sortedThumbnails insertObject:newArray1 atIndex:0];
                NSMutableArray *newArray2 = [[NSMutableArray alloc] initWithObjects:[self.urlData objectAtIndex:i], nil];
                [sortedUrls insertObject:newArray2 atIndex:0];
                NSMutableArray *newArray3 = [[NSMutableArray alloc] initWithObjects:[self.thumbnailsUrls objectAtIndex:i], nil];
                [sortedThumbnailsUrls insertObject:newArray3 atIndex:0];
                firstTime = NO;
            }else{
            [[sortedData firstObject] addObject:[self.tableData objectAtIndex:i]];
            [[sortedThumbnails firstObject] addObject:[self.thumbnails objectAtIndex:i]];
            [[sortedUrls firstObject] addObject:[self.urlData objectAtIndex:i]];
            [[sortedThumbnailsUrls firstObject] addObject:[self.thumbnailsUrls objectAtIndex:i]];
                firstTime = NO;}
        }else{
            if (firstLetter!=currentPrefix) {
                [firstLetters addObject:firstLetter];
            }
        
            if ([currentPrefix isEqualToString:firstLetter]) {
                [[sortedData lastObject] addObject:[self.tableData objectAtIndex:i]];
                [[sortedThumbnails lastObject] addObject:[self.thumbnails objectAtIndex:i]];
                [[sortedUrls lastObject] addObject:[self.urlData objectAtIndex:i]];
                [[sortedThumbnailsUrls lastObject] addObject:[self.thumbnailsUrls objectAtIndex:i]];
            }
        
            else {
                NSMutableArray *newArray = [[NSMutableArray alloc] initWithObjects:[self.tableData objectAtIndex:i], nil];
                [sortedData addObject:newArray];
                NSMutableArray *newArray1 = [[NSMutableArray alloc] initWithObjects:[self.thumbnails objectAtIndex:i], nil];
                [sortedThumbnails addObject:newArray1];
                NSMutableArray *newArray2 = [[NSMutableArray alloc] initWithObjects:[self.urlData objectAtIndex:i], nil];
                [sortedUrls addObject:newArray2];
                NSMutableArray *newArray3 = [[NSMutableArray alloc] initWithObjects:[self.thumbnailsUrls objectAtIndex:i], nil];
                [sortedThumbnailsUrls addObject:newArray3];
            }
        
            currentPrefix = firstLetter;
        }
    }
    
    ///////////    ///////////    ///////////    ///////////
    
    //NSLog(@"%@",firstLetters);

    self.tableDataFirstLetters = firstLetters;
    self.tableData = sortedData;
    self.urlData = sortedUrls;
    self.thumbnails = sortedThumbnails;
    self.thumbnailsUrls = sortedThumbnailsUrls;
    
    self.numberOfSections = self.tableData.count;
    self.sectionsCount = [[NSMutableArray alloc]init];
    
    self.sectionIndexTitles = [[NSMutableArray alloc] initWithArray:self.tableDataFirstLetters];
    if ([[self.sectionIndexTitles objectAtIndex:0]isEqualToString:self.category]) {
        [self.sectionIndexTitles replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"★"]];
    }
    
    
    for (int i = 0; i < self.numberOfSections; i++) {
        [self.sectionsCount addObject:[NSNumber numberWithInt:[[self.tableData objectAtIndex:i]count]]];
        //NSLog(@"daddsd %lu",(unsigned long)[[self.tableData objectAtIndex:i]count] );
    }
    for (int i = 0; i < self.numberOfSections; i++) {
        for (int j = 0; j < [[self.sectionsCount objectAtIndex:i]integerValue]; j++) {
            //NSLog(@" %i %i", i , [[self.sectionsCount objectAtIndex:j]integerValue] );
            NSString *url = [[self.thumbnailsUrls objectAtIndex:i] objectAtIndex:j];
    
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
        controller.pageTitle = [[self.tableData objectAtIndex:
                                [[self.subTableView indexPathForSelectedRow] section]]
    objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
    controller.url = [[self.urlData objectAtIndex:
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

-(void)downloadAndSortData{
    [characters downloadJsonData];
    // NSLog(@"%@",self.category);
    while (![characters getTopTitles]) {
        usleep(50000);
    }
    
    [characters sortInAlphabeticalOrder];
    //NSLog(@"%@",[characters getTopTitles]);
    _tableData = [characters getTopTitles];
    _urlData = [characters getTopUrls];
    _thumbnailsUrls = [characters getTopThumbnails];
    for (int i = 0; i < characters.topTitles.count; i++) {
        [_thumbnails addObject:[self genereteBlankImage]];
    }
    [self.subTableView reloadData];
}

#pragma mark table view

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    //NSLog(@"%i",self.numberOfSections);
    return self.numberOfSections;
}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sectionsCount objectAtIndex:section]integerValue];
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

    cell.textLabel.text = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
    return [self.tableDataFirstLetters objectAtIndex:section];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
        return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark other

//-(void)downloadImages{
//    for (int i = 0; i < characters.topTitles.count; i++) {
//        __block __weak NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
//            //if([downloadImageOperation isCancelled]){return;}
//            
//            UIImage *image = [self downloadImageWithUrl:[[characters getTopThumbnails]objectAtIndex:i]];
//            if([downloadImageOperation isCancelled]){return;}
//            if(image!=nil && ![downloadImageOperation isCancelled]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if([downloadImageOperation isCancelled]){return;}
//                    [_thumbnails replaceObjectAtIndex:i withObject:image];
//                    if([downloadImageOperation isCancelled]){return;}
//                    //[self.subTableView reloadData];
//                    if ([[self.subTableView indexPathsForVisibleRows] containsObject:[NSIndexPath indexPathForRow:i inSection:0]]) {
//                        [self.subTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
//                                                 withRowAnimation:UITableViewRowAnimationFade];
//                    }
//                });
//            }
//        }];
//        [self.loadingThumbnailsQueue addOperation:downloadImageOperation];
//    }
//}

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

- (NSString *)replaceCharacters:(NSString *)string{
    
    string = [string stringByReplacingOccurrencesOfString:@" "
                                             withString:@"_"];
    string = [string stringByReplacingOccurrencesOfString:@"$"
                                               withString:@"%24"];
    return string;
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
