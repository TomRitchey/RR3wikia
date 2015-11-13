//
//  JsonDataGetter.h
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonDataGetterParent.h"

@interface JsonDataGetter : JsonDataGetterParent


@property (strong, nonatomic) NSMutableArray *topThumbnails;
@property (strong, nonatomic) NSMutableArray *topUrls;


-(id)init;
-(id)initWithLimit:(int)limit;
-(id)initWithURL:(NSString*)stringURL;
-(id)initWithCategory:(NSString*)category withLimit:(int)limit;
-(void)sortInAlphabeticalOrder;
-(NSMutableArray*)getTopTitles;
-(NSMutableArray*)getTopUrls;
-(NSMutableArray*)getTopThumbnails;
@end
