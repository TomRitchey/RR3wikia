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
    
    [self downloadAndSortData];

    
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
        WebViewController *controller = (WebViewController *)segue.destinationViewController;
        controller.pageTitle = [self.tableData objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
        controller.url = [self.urlData objectAtIndex:[[self.subTableView indexPathForSelectedRow] row]];
}

-(void)downloadAndSortData{
    [characters downloadJsonData];
    // NSLog(@"%@",self.category);
    while (![characters getTopTitles]) {
        usleep(50000);
        
        // NSLog(@"%@",characters);
        
    }
    
    [characters sortInAlphabeticalOrder];
    //NSLog(@"%@",[characters getTopTitles]);
    _tableData = [characters getTopTitles];
    _urlData = [characters getTopUrls];
    for (int i = 0; i < characters.topTitles.count; i++) {
        [_thumbnails addObject:[self genereteBlankImage]];
    }
    for (int i = 0; i < characters.topTitles.count; i++) {
        __block __weak NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
            //if([downloadImageOperation isCancelled]){return;}
            
            UIImage *image = [self downloadImageWithUrl:[[characters getTopThumbnails]objectAtIndex:i]];
            if([downloadImageOperation isCancelled]){return;}
            if(image!=nil && ![downloadImageOperation isCancelled]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([downloadImageOperation isCancelled]){return;}
                    [_thumbnails replaceObjectAtIndex:i withObject:image];
                    if([downloadImageOperation isCancelled]){return;}
                    //[self.subTableView reloadData];
                    if ([[self.subTableView indexPathsForVisibleRows] containsObject:[NSIndexPath indexPathForRow:i inSection:0]]) {
                        [self.subTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                 withRowAnimation:UITableViewRowAnimationFade];
                    }
                });
            }
        }];
        [self.loadingThumbnailsQueue addOperation:downloadImageOperation];
    }
    [self.subTableView reloadData];
}

#pragma mark table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.imageView.image = [_thumbnails objectAtIndex:indexPath.row];
    cell.textLabel.text = [_tableData objectAtIndex:indexPath.row];
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

@end
