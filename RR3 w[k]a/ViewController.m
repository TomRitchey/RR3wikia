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
    charactersExtracted.delegate = self;
    
    self.navigationItem.title  = self.category;
    self.loadingThumbnailsQueue = [[NSOperationQueue alloc] init];
    self.loadingThumbnailsQueue.maxConcurrentOperationCount = 30;
    
    _thumbnails = [[NSMutableArray alloc]init];
    
    if([self checkIfNetworkAwaliable]){
       // __block NSBlockOperation *downloadDataOperation = [NSBlockOperation blockOperationWithBlock:^{
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [charactersExtracted preparation];
         });
        //}];
       // [self.loadingDataQueue addOperation:downloadDataOperation];
       
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


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.loadingThumbnailsQueue cancelAllOperations];
    [charactersExtracted masterViewControllerRemoved];
   
}

-(void)didFinishExtracting{
    [self dataExtractedAction];
}

-(void)dataExtractedAction{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.subTableView reloadData];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        self.thumbnails = charactersExtracted.thumbnails;
        
        
        for (int i = 0; i < charactersExtracted.numberOfSections; i++) {
            for (int j = 0; j < [[charactersExtracted.sectionsCount objectAtIndex:i]integerValue]; j++) {
                
                NSString *url = [[charactersExtracted.thumbnailsUrls objectAtIndex:i] objectAtIndex:j];
                
                ImageBackgroundDownload *custom = [[ImageBackgroundDownload alloc] init];
                // assign delegate
                custom.delegate = self;
                [custom downloadImageWithUrl:url forIndexPath:[NSIndexPath indexPathForRow:j inSection:i] inArray:self.thumbnails forQueue:(NSOperationQueue*)self.loadingThumbnailsQueue];
            }
        }
        
    });
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

-(void)imageDidFinishDownloading{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.subTableView reloadData];
    });
}

-(void)imageDidFinishDownloadingForIndexPath:(NSIndexPath*)indexPath{
    
        if ([[self.subTableView indexPathsForVisibleRows] containsObject:indexPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.subTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                         withRowAnimation:UITableViewRowAnimationFade];
            }
            @catch (NSException *exception) {
                [self.subTableView reloadData];
            }

        });
    }
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
