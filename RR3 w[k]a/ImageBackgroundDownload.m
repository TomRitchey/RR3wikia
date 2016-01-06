//
//  ImageBackgroundDownload.m
//  RR3wikia
//
//  Created by Kacper Augustyniak on 03/01/2016.
//  Copyright © 2016 Kacper Augustyniak. All rights reserved.
//

#import "ImageBackgroundDownload.h"

@implementation ImageBackgroundDownload

-(instancetype)init {
    
    self = [super init];
    
    return self;
    
}

-(void)downloadImageWithUrl:(NSString*)url forIndexPath:(NSIndexPath*)indexPath inArray:(NSMutableArray*)Array forQueue:(NSOperationQueue*)queue{
    
    __block NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *image = [JsonDataExtractor downloadImageWithUrl:url];
            if (operation.isCancelled) {
                return ;
            }
        if(image!=nil){
                //UIImage* image = [UIImage imageWithData:imageData];
                [[Array objectAtIndex:indexPath.section]replaceObjectAtIndex:indexPath.row withObject:image];
        }
    
    @try {
        [_delegate imageDidFinishDownloadingForIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        [_delegate imageDidFinishDownloading];
    }
    @finally {
        
    }
    }];
    
    [queue addOperation:operation];
    //[_delegate imageDidFinishDownloading];
}

@end
