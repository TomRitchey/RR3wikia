//
//  JsonDataExtractor.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 15.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "JsonDataExtractor.h"

@implementation JsonDataExtractor
-(instancetype)init {
    
    self = [super init];
    
    return self;
    
}


-(id)initWithCategory:(NSString*)category{
    self = [self init];
    if (!(self = [super init]))
    {return nil;}
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.category = category;
    //_loadingQueue = [[NSOperationQueue alloc] init];
    [self addObserver:self forKeyPath:@"self.characters.dataDownloaded" options:NSKeyValueObservingOptionOld context:NULL];
    
    self.loadingDataQueue = [[NSOperationQueue alloc] init];
    return self;
    
}
- (void)dealloc{
    @try{
        [self removeObserver:self forKeyPath:@"self.characters.dataDownloaded"];
        NSLog(@" observer removed ");
    }@catch(id anException){
        NSLog(@" no observer ");
    }
}
-(void)masterViewControllerRemoved{
   // [self.characters dealloc];
    [self.loadingDataQueue cancelAllOperations];
    //NSLog(@"cancelec");
}

-(void)removeObservers{
    [self removeObserver:self forKeyPath:@"self.characters.dataDownloaded"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"self.characters.dataDownloaded"]&& self.characters.dataDownloaded == YES) {
        //NSLog(@"ex self data = %hhd",self.characters.dataDownloaded);
        //NSLog(@"Json  is here");
        
        __block NSBlockOperation *downloadDataOperation = [NSBlockOperation blockOperationWithBlock:^{
            
            [self downloadAndSortData];
            }];
        [self.loadingDataQueue addOperation:downloadDataOperation];
    }
}

-(void)preparation{
    
    //self.category = [self replaceCharacters:self.category];
    _thumbnails = [[NSMutableArray alloc]init];
    self.characters = [[JsonDataGetter alloc] initWithCategory:[self replaceCharacters:self.category] withLimit:200];
    self.tableDataFirstLetters = [[NSMutableArray alloc] init];
    
    __block NSBlockOperation *downloadDataOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self.characters downloadJsonData];
    }];
    [self.loadingDataQueue addOperation:downloadDataOperation];
    ///////////    ///////////    ///////////    ///////////

}
-(void)downloadAndSortData{
//__block NSBlockOperation *downloadDataOperation = [NSBlockOperation blockOperationWithBlock:^{
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.characters sortInAlphabeticalOrder];
    //NSLog(@"%@",[characters getTopTitles]);
    _tableData = [self.characters getTopTitles];
    _urlData = [self.characters getTopUrls];
    _thumbnailsUrls = [self.characters getTopThumbnails];
    for (int i = 0; i < self.characters.topTitles.count; i++) {
        [_thumbnails addObject:[JsonDataExtractor genereteBlankImage]];
    }
    
    //if([downloadDataOperation isCancelled]) return;
    
    NSString *currentPrefix;
    NSMutableArray* sortedData = [[NSMutableArray alloc] init];
    NSMutableArray* sortedThumbnails = [[NSMutableArray alloc] init];
    NSMutableArray* sortedUrls = [[NSMutableArray alloc] init];
    NSMutableArray* sortedThumbnailsUrls = [[NSMutableArray alloc] init];
    
    NSMutableArray* firstLetters = [[NSMutableArray alloc] init];
    
    bool firstTime = YES;
    for (int i=0;i<self.tableData.count;i++){
        NSString *firstLetter = [[self.tableData objectAtIndex:i]substringToIndex:1];
        
        //if([downloadDataOperation isCancelled]) return;
        
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
    
    //if([downloadDataOperation isCancelled]) return;
    
    self.tableDataFirstLetters = firstLetters;
    self.tableData = sortedData;
    self.urlData = sortedUrls;
    self.thumbnails = sortedThumbnails;
    self.thumbnailsUrls = sortedThumbnailsUrls;
    
    self.numberOfSections = self.tableData.count;
    self.sectionsCount = [[NSMutableArray alloc]init];
    
    self.sectionIndexTitles = [[NSMutableArray alloc] initWithArray:self.tableDataFirstLetters];
    NSLog(@"%@",self.category);
    if ([[self.sectionIndexTitles objectAtIndex:0]isEqualToString:self.category]) {
        [self.sectionIndexTitles replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"★"]];
    }
    
    
    //if([downloadDataOperation isCancelled]) return;
    
    for (int i = 0; i < self.numberOfSections; i++) {
        [self.sectionsCount addObject:[NSNumber numberWithInt:[[self.tableData objectAtIndex:i]count]]];
        //NSLog(@"daddsd %lu",(unsigned long)[[self.tableData objectAtIndex:i]count] );
    }

    [_delegate didFinishExtracting];
        //});
   // }];
   // [_loadingQueue addOperation:downloadDataOperation];
}
//function not in use
//+(void)downloadImage:(NSString*)url forIndexPath:(NSIndexPath*)indexPath inArray:(NSMutableArray*)Array inOperationQueue:(NSOperationQueue*)operationQueue{
//    
//    __block NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
//        if([downloadImageOperation isCancelled]){return;}
//        UIImage *image = [JsonDataExtractor downloadImageWithUrl:url];
//        if([downloadImageOperation isCancelled]){return;}
//        if(image!=nil && ![downloadImageOperation isCancelled]){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if([downloadImageOperation isCancelled]){return;}
//                [[Array objectAtIndex:indexPath.section]replaceObjectAtIndex:indexPath.row withObject:image];
//                if([downloadImageOperation isCancelled]){return;}
//            });
//        }
//    }];
//    [operationQueue addOperation:downloadImageOperation];
//}


+(UIImage *)downloadImageWithUrl:(NSString *)url{
    UIImage *tempImage;
    if(url == [NSNull null]){
        tempImage = [JsonDataExtractor genereteBlankImage];
    }else{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        tempImage = [UIImage imageWithData:imageData];
    }
    return tempImage;
}


+(UIImage *)genereteBlankImage {
    
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
-(NSString *)replaceCharacters:(NSString *)string{
    
    string = [string stringByReplacingOccurrencesOfString:@" "
                                               withString:@"_"];
    string = [string stringByReplacingOccurrencesOfString:@"$"
                                               withString:@"%24"];
    return string;
}

@end
