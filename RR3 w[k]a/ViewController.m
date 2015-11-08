//
//  ViewController.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
        JsonDataGetter *characters;
}
@property NSMutableArray *thumbnails;
@property NSMutableArray *tableData;
    

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSOperationQueue *loadingThumbnailsQueue = [[NSOperationQueue alloc] init];

    _thumbnails = [[NSMutableArray alloc]init];
    characters = [[JsonDataGetter alloc] initWithCategory:@"Cars_A-Z" withLimit:200];
    [characters downloadJsonData];
    
    while (![characters getTopTitles]) {
        usleep(50000);
        
    }
    
    [characters sortInAlphabeticalOrder];
    //NSLog(@"%@",[characters getTopTitles]);
    _tableData = [characters getTopTitles];
    for (int i = 0; i < characters.topTitles.count; i++) {
        [_thumbnails addObject:[self genereteBlankImage]];
        __block __weak NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *image = [self downloadImageWithUrl:[[characters getTopThumbnails]objectAtIndex:i]];
            if(image!=nil && ![downloadImageOperation isCancelled]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_thumbnails replaceObjectAtIndex:i withObject:image];
                    [self.detailTableView reloadData];
                });
            }
        }];
        [loadingThumbnailsQueue addOperation:downloadImageOperation];
    }
    [self.detailTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    return cell;
}

-(UIImage *)downloadImageWithUrl:(NSString *)url{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *tempImage = [UIImage imageWithData:imageData];
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
