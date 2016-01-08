//
//  JsonDataExtractor.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 15.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "JsonDataGetter.h"

@protocol JsonDataExtractorDelegate <NSObject>

@required
-(void)didFinishExtracting;

@end

@interface JsonDataExtractor : NSObject <JsonDataGetterDelegate>

@property JsonDataGetter *characters;

@property NSMutableArray *thumbnailsUrls;
@property NSMutableArray *thumbnails;
@property NSMutableArray *tableData;
@property NSMutableArray *tableDataFirstLetters;
@property NSMutableArray *sectionIndexTitles;
@property NSMutableArray *urlData;
@property NSString *category;
@property NSInteger numberOfSections;
@property NSMutableArray *sectionsCount;

@property NSOperationQueue *loadingDataQueue;

@property (atomic, weak) id  delegate;

-(void)masterViewControllerRemoved;
-(void)downloadAndSortData;
-(void)preparation;
-(id)initWithCategory:(NSString*)category;
+(UIImage *)genereteBlankImage;
+(UIImage *)downloadImageWithUrl:(NSString *)url;
-(void)removeObservers;
@end
