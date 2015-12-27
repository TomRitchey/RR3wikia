//
//  ViewController.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, copy) NSArray *previousNavStack;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     //NSLog(@"will load");
    
    charactersExtracted = [[JsonDataExtractor alloc] initWithCategory:self.category];
    [self addObserver:self forKeyPath:@"charactersExtracted.dataExtracted" options:NSKeyValueObservingOptionOld context:NULL];
    
//    NSLog(@"%@",[self class]);
    
    self.loadingThumbnailsQueue.maxConcurrentOperationCount = 30;
    self.navigationItem.title  = self.category;
    self.loadingThumbnailsQueue = [[NSOperationQueue alloc] init];

    _thumbnails = [[NSMutableArray alloc]init];
    
    if([self checkIfNetworkAwaliable]){
        //[self downloadAndSortData];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
            [charactersExtracted preparation];
        });
    }else{
            [self showErrorMessage];
    }
    ///////////    ///////////    ///////////    ///////////
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"mem warning");
    // Dispose of any resources that can be recreated.
}

//-(void)viewDidAppear:(BOOL)animated{
//    //[self addObserver:self forKeyPath:@"charactersExtracted.dataExtracted" options:NSKeyValueObservingOptionOld context:NULL];
//    NSLog(@"added");
//}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    //viewWillAppear: and viewWillDisappear: are not called by navigationController
    // when a view controller is pushed on or popped off the stack.
    // Therefore, we have to do it manually.
    if ([self.previousNavStack count] > 0) //will be empty at launch
        [[self.previousNavStack lastObject] viewWillDisappear:animated];
    [[navigationController.viewControllers lastObject] viewWillAppear:animated];
    self.previousNavStack = navigationController.viewControllers;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[charactersExtracted removeObservers];
    [charactersExtracted masterViewControllerRemoved];
    @try {
        [self removeObserver:self forKeyPath:@"charactersExtracted.dataExtracted"];
    }
    @catch (NSException *exception) {
        NSLog(@"no observer");
    }
    if (self.isMovingToParentViewController || self.isBeingDismissed) {
         NSLog(@"bye");
       // [self.loadingThumbnailsQueue cancelAllOperations];
    }
    //NSLog(@"bye 0");
    [self.loadingThumbnailsQueue cancelAllOperations];
    [charactersExtracted masterViewControllerRemoved];
   
}

//- (void)willMoveToParentViewController:(UIViewController *)parent{
//    [super willMoveToParentViewController:parent];
//    NSLog(@"bye 1");
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:@"charactersExtracted.dataExtracted"]&& charactersExtracted.dataExtracted == YES) {
        //NSLog(@" self data = %hhd",charactersExtracted.characters.dataDownloaded);
        self.thumbnails = charactersExtracted.thumbnails;
        [self.tableView reloadData];
        
        
       // __block NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < charactersExtracted.numberOfSections; i++) {
            for (int j = 0; j < [[charactersExtracted.sectionsCount objectAtIndex:i]integerValue]; j++) {
                NSString *url = [[charactersExtracted.thumbnailsUrls objectAtIndex:i] objectAtIndex:j];
                    // if([downloadImageOperation isCancelled]){return;}
                     [self downloadImage:url forIndexPath:[NSIndexPath indexPathForRow:j inSection:i] inArray:self.thumbnails];
                
            }
        }
        //}];
        
        //[self.loadingThumbnailsQueue addOperation:downloadImageOperation];
        
        [self.tableView reloadData];
        //NSLog(@"downloaded %@ " , charactersExtracted.tableData);
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        WebViewController *controller = (WebViewController *)segue.destinationViewController;
        controller.pageTitle = [[charactersExtracted.tableData objectAtIndex:
                                [[self.subTableView indexPathForSelectedRow] section]]
    objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
    controller.url = [[charactersExtracted.urlData objectAtIndex:
                       [[self.subTableView indexPathForSelectedRow] section]]
                      objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return charactersExtracted.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[charactersExtracted.sectionsCount objectAtIndex:section]integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark tiny alphabet on the right

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [charactersExtracted.tableDataFirstLetters objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return charactersExtracted.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark images

-(void)downloadImage:(NSString*)url forIndexPath:(NSIndexPath*)indexPath inArray:(NSMutableArray*)Array{
  
    __block NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
        if([downloadImageOperation isCancelled]){return;}
        UIImage *image = [JsonDataExtractor downloadImageWithUrl:url];
        //NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if([downloadImageOperation isCancelled]){return;}
    if(image!=nil && ![downloadImageOperation isCancelled]){
            dispatch_async(dispatch_get_main_queue(), ^{
                //UIImage* image = [UIImage imageWithData:imageData];
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
