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
    
    self.navigationItem.title  = self.category;
    self.category = [self.category stringByReplacingOccurrencesOfString:@" "
                                                   withString:@"_"];
    self.loadingThumbnailsQueue = [[NSOperationQueue alloc] init];

    _thumbnails = [[NSMutableArray alloc]init];
    characters = [[JsonDataGetter alloc] initWithCategory:self.category withLimit:200];
    [characters downloadJsonData];
    
    while (![characters getTopTitles]) {
        usleep(50000);
        
    }
    
    [characters sortInAlphabeticalOrder];
    //NSLog(@"%@",[characters getTopTitles]);
    _tableData = [characters getTopTitles];
    _urlData = [characters getTopUrls];
    for (int i = 0; i < characters.topTitles.count; i++) {
        [_thumbnails addObject:[self genereteBlankImage]];
        __block __weak NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
            //if([downloadImageOperation isCancelled]){return;}
            
            UIImage *image = [self downloadImageWithUrl:[[characters getTopThumbnails]objectAtIndex:i]];
            if(image!=nil && ![downloadImageOperation isCancelled]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_thumbnails replaceObjectAtIndex:i withObject:image];
                    [self.subTableView reloadData];
                });
            }
        }];
        [self.loadingThumbnailsQueue addOperation:downloadImageOperation];
    }
    [self.subTableView reloadData];
    
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

@end
