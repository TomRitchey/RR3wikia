//
//  ImageBackgroundDownload.h
//  RR3wikia
//
//  Created by Kacper Augustyniak on 03/01/2016.
//  Copyright © 2016 Kacper Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonDataExtractor.h"

@protocol ImageDownloadDelegate <NSObject>

@required
-(void)imageDidFinishDownloading;

@optional
-(void)imageDidFinishDownloadingForIndexPath:(NSIndexPath*)indexPath;

@end

@interface ImageBackgroundDownload : NSObject

@property (atomic, weak) id  delegate;

-(void)downloadImageWithUrl:(NSString*)url forIndexPath:(NSIndexPath*)indexPath inArray:(NSMutableArray*)Array forQueue:(NSOperationQueue*)queue;

@end
